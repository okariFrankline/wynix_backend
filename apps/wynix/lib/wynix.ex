defmodule Wynix do
  @moduledoc """
  Wynix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Wynix.{Accounts, Skills, Contracts, Repo}
  alias Wynix.Contracts.{Bid, Order, Practise}
  #alias Wynix.Accounts.{User, Account}
  alias Wynix.Utils.{Generator}
  import Ecto.Query

  @spec create_user(:client | :practise, map) :: {:error, Ecto.Changeset} | {:ok, Accounts.Account}
  @doc """
    Create user creates a user together with his/her account and practise depending on the account type
  """
  def create_user(:practise, %{"password" => password, "account_type" => acc_type, "auth_email"=> email, "practise_type" => practise_type, "practise_name" => prac_name}) do
    with {:ok, user} <- Accounts.create_user(%{"auth_email"=> email, "password" => password}) do
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
        account_code: Generator.generate()
      })
      # create the account
      |> Repo.insert!()

      # start a task to create the practise
      Supervisor.start_link([
        {Task, fn ->
          # create the practise for the user
          %Skills.Account{id: account.id, account_holder: account.account_holder}
          # createa new practise struct
          |> Ecto.build_assoc(:practise, %{
            practise_name: prac_name,
            practise_type: practise_type,
            practise_code: Generator.generate()
          })
          # insert into the db
          |> Repo.insert!()

        end}
      ], strategy: :one_for_one)

      # return the account
      {:ok, account}
    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end fo create_user/2 for practise

  def create_user(:client, %{"password" => password, "account_type" => acc_type, "auth_email"=> email}) do
    with {:ok, user} <- Accounts.create_user(%{"auth_email"=> email, "password" => password}) do
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
        account_code: Generator.generate()
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
        Supervisor.start_link([
          {Task, fn ->
            Contracts.delete_order(order)
          end}
        ], strategy: :one_for_one)
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
      with {:ok, _bid} = result <- Contracts.create_bid(Map.merge(bid_params,
        %{"practise_id" => practise_id, "owner_name" => practise_name, "order_id" => order.id})) do
        # start a supervised task to create a token history of type "Bid token
        Supervisor.start_link([
          {Task, fn ->
            # get the account
            account = Skills.get_practise!(practise_id) |> Repo.preload(:account)
            # create a new token history for the account and reduce the bid tokens of the account by one
            with {:ok, _token} <- Accounts.create_token_history(%{order_id: order_id, token_type: "Bid Token", account_id: account.id }) do
              # update the account by reducing the number of bid token
              account
              # change the bid-tokens by one
              |> Ecto.Changeset.change(%{
                bid_tokens: account.bid_tokens - 1
              })
              # update the account
              |> Repo.update()
            end # end of with for creating a token

          end}
        ], strategy: :one_for_one)
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
    # start a supervised process for rejecting a bid
    Supervisor.start_link([
      {Task, fn ->
        # get the bid
        with bid <- Contracts.get_bid!(bid_id),
          # update the bid
          {:ok, _bid} <- bid |> Ecto.Changeset.change(%{status: "Rejected"}) |> Repo.update() do
          # send the owner of the bid a notification
          send_bid_owner_notification(bid.practise_id, :order_cancelled)
        end # end of rejecting the bid
      end}
    ], strategy: :one_for_one)
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
    # get the order
    bid = Contracts.get_order!(bid_id) |> Repo.preload([
      # load only the id of the practise
      practise: from(practise in Practise, select: [practise.id]),
      # load on the contractors needed and the id
      order: from(order in Order, select: [order.contractors_needed, order.id])
    ])

    # assign the contract
    with %Order{} = order <- assign_order(bid.practise, bid.order, bid.id) do
      # start a process that accepts the given bid
      Supervisor.start_link([
        {Task, fn ->
          Contracts.update_bid(bid, %{status: "Accepted"})
          # send a notification to the owner of the bid
          send_bid_owner_notification(bid.practise_id, :accepted)
        end}
      ], strategy: :one_for_one)
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
        # start a process for rejecting all the bids made for this order
        Supervisor.start_link([
          {Task, fn ->
            with bids when bids != [] <- order.bids do
              # for each of the bids, reject then
              Stream.each(bids, fn bid ->
                # start a supervised tak for rejecting the bid
                Supervisor.start_link([
                  {Task, fn ->
                    with {:ok, _bid} <- bid |> Ecto.Changeset.change(%{status: "Rejected"}) |> Repo.update() do
                      # send the owner of the bid a notification
                      send_bid_owner_notification(bid.practise_id, :order_cancelled)
                    end # end of rejecting the bid
                  end} # end of task for rejecting a single bid
                ], strategy: :one_for_one)
              end)
            end # end with for checking if the order has bids
          end} # end of tak for running the stream for each of the bids

        ], strategy: :one_for_one)
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
    from(
      bid in Bid,
      where: bid.order_id == ^order_id,
      where: bid.status != "Rejected",
      select: [bid.id, bid.owner_name, bid.practise_id, bid.asking_amount, bid.deposit_amount]
    )
    # return all the bids
    |> Repo.all()
  end # end of get_bids_for_order/1


  defp assign_order(%Practise{} = practise, %Order{contractors_needed: number} = order, bid_id) when number - 1 == 0 do
    # start a supervised process for rejecting each of the bids
    Supervisor.start_link([
      {Task, fn ->
        # preload all the bids
        bids = order |> Repo.preload([
          bids: from(
            bid in Bid,
            where: bid.id != ^bid_id,
            where: bid.status == "Pending"
          )
        ])
        # for each of the bids, reject them    has_many :orders, Wynix.Contracts.Order
        Stream.each(bids, fn bid ->
          # for each of the bids in the list start a supervised process to reject the orders
          Supervisor.start_link([
            {Task, fn ->
              Contracts.update_bid(bid, %{status: "Rejected."})
              # send a notification to the owner of the bid
            end} # end of the task for rejecting a given bid
          ], strategy: :one_for_one)
          |> Stream.run()
        end) # end of the stream function
      end} # end of the task for rejecting all the bids
    ], strategy: :one_for_one)

    # return the changeset
    practise
    # add the practise id and update the status and the number of contractors needed
    |> Ecto.build_assoc(:orders, %{
      status: "Assigned",
      contractors_needed: 0
    })
    |> merge_and_update_orders(order)
  end # end of assign order

  defp assign_order(%Practise{} = practise, %Order{} = order, _bid_id) do
    practise
    # add the build_assoc
    |> Ecto.build_assoc(:orders, %{
      contractors_needed: order.number - 1
    })
    |> merge_and_update_orders(order)
  end # end of assign order

  # function for updating the merge_and_update_orders
  defp merge_and_update_orders(new_order, old_order) do
    old_order
    |> Map.merge(new_order)
    |> Repo.update()
    # preload the practises
    |> Repo.preload([:practises])
  end

  # send_bid_owner_bid otification
  def send_bid_owner_notification(_practise_id, reason) do
    reason
  end

end # function for creating a user
