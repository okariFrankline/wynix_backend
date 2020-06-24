defmodule Wynix do
  @moduledoc """
  Wynix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Wynix.{Accounts, Skills, Contracts}

  @doc """
    Create user creates a user together with his/her account and practise depending on the account type
  """
  def create_user(:practise, attrs) do
    with {:ok, user} <- Accounts.create_user(attrs) do
      # create an account for the user
      {:ok, account} = user |> Ecto.build_assoc(attrs) |> Accounts.create_account()
      # create the practise
      {:ok, practise} = account |> Ecto.build_assoc(attrs) |> Skills.create_practise()
      # preload the practise and the account
      {:ok, %{
        user: user,
        account: account,
        practise: practise
      }}

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

      # not payment update
      _ ->
        # update the order
        Contracts.update_order(order, order_attributes)
    end # end of type
  end # end of update_order/2

  @doc """
    Create bid creates a bid for a given order and for a given user
  """
  def create_bid(%Skills.Practise{id: owner_id, practise_name: owner_name} = _owner, %Contracts.Order{id: order_id} = order, attrs) do
    # start a supervised process to create the bid
    Supervisor.start_link([
      {Task, fn ->
        # create a bid with added values for the attrs by adding the order_id, practise_id and the owner_name
        Contracts.create_bid(%{attrs | practise_id: owner_id, owner_name: owner_name, order_id: order_id})
      end}
    ])
    # return ok
    :ok
  end # end of create_bid/3



end # function for creating a user
