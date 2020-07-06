defmodule Wynix do
  @moduledoc """
  Wynix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Wynix.{Accounts, Skills, Contracts, Repo}
  alias Wynix.Contracts.{Bid, Order}
  #alias Wynix.Accounts.{User, Account}
  alias Wynix.Utils.{Generator}
  import Ecto.Query

  @spec create_user(:client | :practise, map) :: {:error, Ecto.Changeset} | {:ok, Accounts.Account}
  @doc """
    Create user creates a user together with his/her account and practise depending on the account type
  """
  def create_user(:practise, %{password: password, account_type: acc_type, auth_email: email, practise_type: practise_type, practise_name: prac_name}) do
    with {:ok, user} <- Accounts.create_user(%{auth_email: email, password: password}) do
      # create an account for the user
      account = user
      # create an association with the user and add the required fields
      |> Ecto.build_assoc(:account, %{
        # set the account type
        account_type: acc_type,
        # set the account name, default to the username
        account_holder: user.username,
        # set the auth email as one of the emails for the account
        emails: [user.auth_email],
        # account code
        account_code: "prac-#{Generator.generate()}"
      })
      # create the account
      |> Repo.insert!()

      # start a task to create the practise
      Task.start(fn ->
        # create the practise for the user
        %Skills.Practise{} |>Ecto.Changeset.change(%{
          practise_name: prac_name,
          practise_type: practise_type,
          practise_code: account.account_code,
          account_id: account.id
        })
        # insert into the db
        |> Repo.insert!()
      end)

      # return the account
      {:ok, account}
    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end fo create_user/2 for practise

  def create_user(:client, %{password: password, account_type: acc_type, auth_email: email}) do
    with {:ok, user} <- Accounts.create_user(%{auth_email: email, password: password}) do
      # create an account for the user
      account = user
      # add the account id and the required information
      |> Ecto.build_assoc(:account, %{
        # set the account type
        account_type: acc_type,
        # set the account name, default to the username
        account_holder: user.username,
        # set the auth email as one of the emails for the account
        emails: [user.auth_email],
        # account code
        account_code: "clt-#{Generator.generate()}"
      })
      # insert the account to the db
      |> Repo.insert!()
      # preload the practise and the account
      {:ok, account}
    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end of create_user for the client/2

  @doc """
    Create order creates an order and creates a new token for the given
  """
  def create_order(%Accounts.Account{id: id, account_holder: holder} = _owner_account, order_attrs) when is_map(order_attrs) do
    # add the order owner to the bid_attrs
    order_attrs = Map.put_new(order_attrs, "order_owner", holder)
    # create the order
    with {:ok, _order} = changeset <- %Contracts.Account{id: id} |> Ecto.build_assoc(:orders) |> Contracts.create_order(order_attrs) do
      # return the order
      changeset
    else
      {:error, _changeset} = changeset -> changeset
    end # end of creating an order
  end # end of the create_order/2

  @doc """
    Updates the contract
  """
  def delete_order(order_id) when is_binary(order_id) do
    # get the order from the dv
    order = Contracts.get_order!(order_id)
    # check the status of the orde
    case order.status do
      "In Progress" ->
        # return an error
        {:error, :assigned}
      # the order has not being assigned.
      _ ->
        # start a supervisor for deleting the order
        Task.start(fn -> Contracts.delete_order(order) end)
        # return ok
        :ok
    end # end of checking the status
  # the order could not be found
  rescue
    Ecto.NoResultsError ->
      # return an error with not found notification
      {:error, :not_found}
  end # end of function for deleting the order

  @doc """
    Create bid creates a bid for a given order and for a given user
  """
  def create_bid(practise_name, practise_id, order_id, bid_params) when is_map(bid_params) do
    # ger order
    order = Contracts.get_order!(order_id)
    # check if the bid is cancelled
    if order.status != "Cancelled" do
      # start task for getting the practise
      practise_task = Task.async(fn -> Skills.get_practise!(practise_id) |> Repo.preload([:account]) end)
      # creat the bid
      with {:ok, _bid} = result <- Contracts.create_bid(Map.merge(bid_params,
        %{"practise_id" => practise_id, "owner_name" => practise_name, "order_id" => order.id})) do
        # get the account
        account = Task.await(practise_task).account.id |> Accounts.get_account!()
        # start a task to create a token history of type "Bid token
        Task.start(fn ->
          # create a new token history for the account and reduce the bid tokens of the account by one
          token_map = %{order_code: order.order_code, token_type: "Bid Token", token_code: "token-#{Generator.generate()}"}
          # create the token history for the account
          with _token <- account |> Ecto.build_assoc(:token_histories, token_map) |> Repo.insert!() do
            # update the account by reducing the number of bid token
            account
            # change the bid-tokens by one
            |> Ecto.Changeset.change(%{
              bid_tokens: account.bid_tokens - 1
            })
            # update the account
            |> Repo.update!()
          end # end of with for creating a token
        end)
        # return response
        result
      end # end of creating the bid
    else
      {:error, :cancelled_order}
    end # end of checking if the order is cancelled
  end # end of create_bid/3

  @doc """
  Rject bid rejects the bid for a given order
  """
  def reject_bid(bid_id) do
    # start a task process for rejecting a bid
    Task.start(fn ->
      # get the bid
      with bid <- Contracts.get_bid!(bid_id),
        # update the bid
        {:ok, _bid} <- bid |> Ecto.Changeset.change(%{status: "Rejected"}) |> Repo.update() do
        # send the owner of the bid a notification
        #send_bid_owner_notification(bid.practise_id, :order_cancelled)
      end # end of rejecting the bid
    end)
    # return ok
    :ok
  end # end of reject_bid/1

  @doc false
  def cancel_bid(bid_id) when is_binary(bid_id) do
    # get teh bid
    bid = Contracts.get_bid!(bid_id)
    # check if the bid has been accepted
    if bid.status != "Accepted" do
      # cancel the bid
      bid
      |> Ecto.Changeset.change(%{
        status: "Cancelled"
      })
      # update the result
      |> Repo.update()

      else
        # return accepted
        :accepted
    end # end of if
  end # end of cancel_bid

  @doc """
    Accepts a bid
  """
  def accept_bid(bid_id) when is_binary(bid_id) do
    # get the order and preload the practise and order
    bid = Contracts.get_bid!(bid_id) |> Repo.preload([:order, :practise])

    # assign the contract
    with {:ok, order} <- assign_order(bid.order, bid.practise, bid.id) do
      # start a process that accepts the given bid
      Task.start(fn ->
        Contracts.update_bid(bid, %{status: "Accepted"})
        # send a notification to the owner of the bid
        #send_bid_owner_notification(bid.practise_id, :accepted)
      end)
      # return the result
      {:ok, order}
    end # end of with for assigning the contract
  end # end of the accept_bid function/3

  @doc """
    Cancel order cancels an order that has been made
  """
  def cancel_order(order_id) do
    # get the order with given id from the db and preload all the bids
    order = Contracts.get_order!(order_id) |> Repo.preload([:bids])
    # check if the order has any practise assigned to it
    if order.practise_id do
      {:error, :already_assigned}
    else
      # cancel the order
      with {:ok, _order} = result <- Ecto.Changeset.change(order, %{status: "Cancelled"}) |> Repo.update() do
        # start a task process for rejecting all the bids made for this order
        Task.start(fn ->
          with bids when bids != [] <- order.bids do
            # for each of the bids, reject then
            Stream.each(bids, fn bid ->
              # start a task for rejecting the bid
              Task.start(fn ->
                with {:ok, _bid} <- bid |> Ecto.Changeset.change(%{status: "Rejected"}) |> Repo.update() do
                  # send the owner of the bid a notification
                  #send_bid_owner_notification(bid.practise_id, :order_cancelled)
                  :ok
                end # end of rejecting the bid
              end) # end of task for rejecting a single bid
            end)
          end # end with for checking if the order has bids
        end) # end of tak for running the stream for each of the bids
        # return the order
        result
      end # end of with for cancelling the order
    end # end of checking if the order has being assigned
  end # end of cancel_order/1

  @doc """
    Gets the bids for a given order
  """
  def get_bids_for_order(order_id) when is_binary(order_id) do
    # query for the orders
    order = Contracts.get_order!(order_id) |> Repo.preload([
      bids: from(
        bid in Bid,
        where: bid.status != "Rejected"
      )
    ])
    # return the bids
    order.bids
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end # end of get_bids_for_order/1


  defp assign_order(%Order{contractors_needed: number} = order, %Contracts.Practise{} = practise, bid_id) when number - 1 == 0 do
    # start a task process for rejecting each of the bids
    Task.start(fn ->
      # preload all the bids
      order = Repo.preload(order, [:bids])
      # for each of the bids, reject them    has_many :orders, Wynix.Contracts.Order
      Stream.each(order.bids, fn bid ->
        # for each of the bids in the list start a supervised process to reject the orders
        if bid.id !== bid_id && bid.status === "Pending" do
          # only reject the bid if it is not the one
          Task.start(fn -> Contracts.update_bid(bid, %{status: "Rejected"}) end)
        end
      end)
      |> Stream.run()
    end) # end of the task for rejecting all the bids

    # update the practise to include the order_id
    with order <- order |> Ecto.Changeset.change(%{status: "Assigned", contractors_needed: 0}) |> Repo.update!(),
      _practise <- practise |> Ecto.Changeset.change(%{order_id: order.id}) |> Repo.update!() do
        # preload the practises
        order = order |> Repo.preload([:practises])
        # return the order
        {:ok, order}
    end # end of updating the order
  end # end of assign order

  defp assign_order(%Order{} = order, %Contracts.Practise{} = practise, _bid_id) do
    # update the practise to include the order_id
    with order <- order |> Ecto.Changeset.change(%{contractors_needed: order.contractors_needed - 1}) |> Repo.update!(),
      # update the practise by adding the order_id.
      _practise <- practise |> Ecto.Changeset.change(%{order_id: order.id}) |> Repo.update!() do
        # preload the practises
          order = order |> Repo.preload([:practises])
          # return the order
          {:ok, order}
    end # end of updating the order
  end # end of assign order

  # send_bid_owner_bid otification
  def send_bid_owner_notification(_practise_id, reason) do
    reason
  end

end # function for creating a user
