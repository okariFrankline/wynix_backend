defmodule WynixWeb.Schema.Orders.Resolver do
  @moduledoc """
    Defines resolver functions for the Account types
  """
  alias Wynix
  alias Wynix.{Contracts}

  @doc false
  def get_order(_parent, args, _resolution) do
    order = Contracts.get_order!(args.order_id)
    # return the order
    {:ok, %{order: order}}
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
  def get_order_bids(_parent, args, _resolution) do
    # get the bids
    case  Wynix.get_bids_for_order(args.order_id) do
      {:ok, order} ->
        # return the order
        {:ok, %{order: order}}

      # the order has no bids that have not being rejected
      {:error, :no_bids} ->
        errors = [
          %{
            key: "bids",
            message: "Order has no active bids yet."
          }
        ]
        # return the response
        {:ok, %{errors: errors}}

      # the order could not be found
      {:error, :order_not_found} ->
        errors = [
          %{
            key: "order",
            message: "Specified order not found."
          }
        ]
        # return the response
        {:ok, %{errors: errors}}
    end # end of getting the wynix
    #
  end # end of get_order_bids/3

  @doc false
  def create_order(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, order} <- Wynix.create_order(account, args.input) do
      # return result
      {:ok, %{order: order}}
    end # end of with
  end # end of create_order/3

  @doc false
  def update_order_service(_parent, args, _resolution) do
    with {:ok, order} <- Contracts.get_order!(args.order_id) |> Contracts.update_order_service(args.input) do
      # return the result
      {:ok, %{order: order}}
    end # end of with
  end # end of update_order_service/3

  @doc false
  def update_order_details(_parent, args, _resolution) do
    # convert the date into a date
    date = Map.fetch!(args.input, :bid_deadline) |> Date.from_iso8601!()
    # update the bid deadline
    input = Map.update!(args.input, :bid_deadline, fn _value -> date end)
    # update the order
    with {:ok, order} <- Contracts.get_order!(args.order_id) |> Contracts.update_order(input) do
      # return the result
      {:ok, %{order: order}}
    end # end of with
  end # end of update_order/3

  @doc false
  def update_order_description(_parent, args, _resolution) do
    with {:ok, order} <- Contracts.get_order!(args.order_id) |> Contracts.update_order_description(%{description: args.description}) do
      # return the result
      {:ok, %{order: order}}
    end # end of with
  end # end of update_order_description/3

  @doc false
  def update_order_payment(_parent, args, _resolution) do
    with {:ok, order} <- Contracts.get_order!(args.order_id) |> Contracts.update_order_payment(args.input) do
      # return the result
      {:ok, %{order: order}}
    end # end of with
  end # end of update_order_payment/3

  @doc false
  def delete_order(_parent, args, _resolution) do

    case Wynix.delete_order(args.order_id) do
      # successful deletion
      :ok ->
        {:ok, %{message: "Order succesfully deleted."}}

      # the order has been assigned
      {:error, :assigned} ->
        errors = [%{
          key: "Deletion Failed",
          message: "Failed. Order has already being assigned."
        }]
        # return response
        {:ok, %{errors: errors}}

      # the order has not been found
        {:error, :not_found} ->
        errors = [%{
          key: "order",
          message: "Failed. Order not found."
        }]
        # return response
        {:ok, %{errors: errors}}

    end # end of case for deleting order
  end # end of delete_order/3

  @doc false
  def cancel_order(_parent, args, _resolution) do
    case Wynix.cancel_order(args.order_id) do
      # order successfully cancelled
      {:ok, order} ->
        # return the order
        {:ok, %{order: order}}

      # order already assigned
      {:error, :already_assigned} ->
        # errors
        errors = [
          %{
            key: "order",
            message: "Failed. Order already assigned."
          }
        ]
        # return the error
        {:ok, %{errors: errors}}

      # error not found
      {:error, :not_found} ->
        # errors
        errors = [
          %{
            key: "order",
            message: "Failed. Order not found."
          }
        ]
        # return the error
        {:ok, %{errors: errors}}
    end # end of canceling the order
  end # end of cancel_order/3

  @doc false
  def accept_bid(_parant, args, _resolution) do
    with {:ok, order} <- Wynix.accept_bid(args.bid_id) do
      # return the result
      {:ok, %{order: order}}
    end # end
  end # end of the accept bid/3


end # end of the accounts resolvers
