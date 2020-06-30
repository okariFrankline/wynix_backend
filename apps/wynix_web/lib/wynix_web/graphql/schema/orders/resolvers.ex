defmodule WynixWeb.Schema.Orders.Resolver do
  @moduledoc """
    Defines resolver functions for the Account types
  """
  alias Wynix
  alias Wynix.{Contracts, Repo}

  @doc false
  def get_order(_parent, args, _resolution) do
    order = Contracts.get_order!(args.id)
    # return the order
    {:ok, order}
  rescue
    Ecto.NoResultsError ->
      errors = [%{
        key: "Not Found",
        message: "Order Not Found"
      }]
      # return the error
      {:ok, %{errors: errors}}
  end # end of get_order/3

  @doc false
  def get_order_bids(_parent, args, _resolution), do: {:ok, Wynix.get_bids_for_order(args.order_id)}

  @doc false
  def create_order(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, _order} = result <- Wynix.create_order(account, args.input) do
      # return result
      result
    end # end of with
  end # end of create_order/3

  @doc false
  def update_order_service(_parent, args, _resolution) do
    with {:ok, _order} = result <- Contracts.get_order!(args.order_id) |> Contracts.update_order_service(args.input) do
      # return the result
      result
    end # end of with
  end # end of update_order_service/3

  @doc false
  def update_order_details(_parent, args, _resolution) do
    with {:ok, _order} = result <- Contracts.get_order!(args.order_id) |> Contracts.update_order(args.input) do
      # return the result
      result
    end # end of with
  end # end of update_order/3

  @doc false
  def update_order_description(_parent, args, _resolution) do
    with {:ok, _order} = result <- Contracts.get_order!(args.order_id) |> Contracts.update_order_description(%{description: args.description}) do
      # return the result
      result
    end # end of with
  end # end of update_order_description/3

  @doc false
  def update_order_payment(_parent, args, _resolution) do
    with {:ok, _order} = result <- Contracts.get_order!(args.order_id) |> Contracts.update_order_payment(args.input) do
      # return the result
      result
    end # end of with
  end # end of update_order_payment/3

  @doc false
  def delete_order(_parent, args, _resolution) do
    # get the order
    order = Contracts.get_order!(args.order_id)
    # delete the order
    with :ok <- Wynix.delete_order(order) do
      {:ok, %{message: "Order succesfully deleted."}}

    else
      :error ->
        errors = [%{
          key: "Deletion Failed",
          message: "Failed. Order has already being assigned."
        }]
        # return response
        {:ok, %{errors: errors}}
    end # end of with
  end # end of delete_order/3


end # end of the accounts resolvers
