defmodule Wynix do
  @moduledoc """
  Wynix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Wynix.{Accounts, Skills, Contracts, Repo}
  alias Wynix.Contracts.{Bid, Order, Practise}
  alias Wynix.Accounts.{User, Account}
  import Ecto.Query

  @doc """
    Create user creates a user together with his/her account and practise depending on the account type
  """
  def create_user(:practise, %{"password" => password, "account_type" => acc_type, "auth_email"=> email, "practise_type" => practise_type}) do
    with {:ok, user} <- Accounts.create_user(%{"auth_email"=> email, "password" => password}) do
      # create an account for the user
      account = user
      # create an association with the user and add the required fields
      |> Ecto.build_assoc(:account, %{
        # set the account type
        account_type: acc_type,
        # set the account name, default to the username
        account_name: user.username,
        # set the auth email as one of the emails for the account
        emails: [user.auth_email]
      })
      # create the account
      |> Repo.insert!()
      # preload the user
      |> Repo.preload([
        user: from(
          user in User,
          select: [user.id, user.token]
        )
      ])
      # start a task to create the practise
      Supervisor.start_link([
        {Task, fn ->
          # create the practise for the user
          Skills.create_practise(%{account_id: account.id, practise_type: practise_type})
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

  def create_user(:client, attrs) do
    with {:ok, user} <- Accounts.create_user(attrs) do
      # create an account for the user
      {:ok, account} = user |> Ecto.build_assoc(attrs) |> Accounts.create_account()
      # preload the practise and the account
      {:ok, %{
        user: user,
        account: account
      }}

    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end of create_user for the client/2

  @doc """
    update practise is used to update information about the practise of a user
  """
  def update_practise(type, %Skills.Practise{} = practise, attrs) when is_atom(type) and is_map(attrs) do
    # check the type and redirect to the correct function
    case type do
      :bio ->
        Skills.update_practise_bio(practise, attrs)
      :countries ->
        Skills.update_practise_countries(practise, attrs)
      :cities ->
        Skills.update_practise_cities(practise, attrs)
      :skills ->
        Skills.update_practise_cities(practise, attrs)
    end # end of checking the type
  end # end of the update_practise

  @doc """
    Create order creates an order and creates a new token for the given
  """
  def create_order(%Accounts.Account{} = owner_account, order_attrs) when is_map(order_attrs) do
    with {:ok, _order} = changeset <- owner_account |> Ecto.build_assoc(order_attrs) do
      # return the order
      changeset
    else
      {:error, _changeset} = changeset -> changeset
    end # end of creating an order
  end # end of the create_order/2

  @doc """
    Updates the contract
  """
  def update_order(type, %Contracts.Order{} = order, order_attributes) when is_atom(type) and is_map(order_attributes) do
    case type do
      :payment ->
        # update the order's payment
        Contracts.update_order_payment(order, order_attributes)
      # updates the service
      :service ->
        # update the order's payment
        Contracts.update_order_service(order, order_attributes)
      # updates the bio
      :bio ->
        # update the order's payment
        Contracts.update_order_bio(order, order_attributes)

      _ ->
        # update the order
        Contracts.update_order(order, order_attributes)
    end # end of type
  end # end of update_order/2

  @doc """
    Create bid creates a bid for a given order and for a given user
  """
  def create_bid(%Skills.Practise{id: owner_id, practise_name: owner_name} = _owner, order_id) do
    # start a supervised process to create the bid
    Supervisor.start_link([
      {Task, fn ->
        # get the order from the db
        with %Order{} = order <- Contracts.get_order!(order_id) do
          # check if the order has been cancelled
          if order.status != "Cancelled" do
            with {:ok, bid} <- Contracts.create_bid(%{practise_id: owner_id, owner_name: owner_name, order_id: order.id}) do
              bid
            end # end of creating the bid
          end # end of checking if the order is cancelled
        else
          _ ->
            :error
        end # end of the with for getting the order
      end}
    ], strategy: :one_for_one)
    # return ok
    :ok
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
  end # end of reject_bid/1

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
    with {:ok, _order} = result <- assign_order(bid.practise, bid.order, bid.id) do
      # start a process that accepts the given bid
      Supervisor.start_link([
        {Task, fn ->
          Contracts.update_bid(bid, %{status: "Accepted"})
          # send a notification to the owner of the bid
          send_bid_owner_notification(bid.practise_id, :accepted)
        end}
      ], strategy: :one_for_one)
      # return the result
      result
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
        # for each of the bids, reject them
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
  end

  # send_bid_owner_bid otification
  def send_bid_owner_notification(_practise_id, reason) do
    reason
  end

end # function for creating a user
