defmodule WynixWeb.Schema.Types.Orders do
  @moduledoc """
    Defines graphql schema types for the orders
  """
  use Absinthe.Schema.Notation
  alias WynixWeb.Schema.Orders.Resolver

  # order
  object :order do
    field :id, non_null(:id)
    field :amount, :float
    field :bid_deadline, :date
    field :contractors_needed, :integer
    field :description, :string
    field :order_category, :string
    field :order_code, :string
    field :order_length, :string
    field :order_type, :string
    field :payable_amount, :string
    field :payment_at, :string
    field :proposal_required, :boolean
    field :status, :string
  end # end of order

  # bid object
  object :bid do
    field :id, non_null(:id)
    field :asking_amount, non_null(:decimal)
    field :deposit_amount, :decimal
    field :practise_id, non_null(:id)
    field :owner_name, non_null(:string)
  end # end of bid object

  # order input
  object :order_input do
    field :order_type, non_null(:string)
    field :order_category, non_null(:string)
  end # end of order input

  # order details input
  object :order_details_input do
    field :proposal_required, non_null(:boolean)
    field :contractors_needed, non_null(:integer)
    field :order_length, non_null(:string)
    field :bid_deadline, non_null(:date)
  end # end of the order_details_input

  # order payment info
  object :order_payment do
    field :payment_at, non_null(:string)
    field :payable_amount, non_null(:decimal)
    field :currency, non_null(:string)
  end # end of order payment

  # order error
  object :order_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end # end of order_error

  # order result
  object :order_result do
    field :order, :order
    field :errors, list_of(:order_error)
  end # end of order result

  # delete_result
  object :delete_result do
    field :message, :string
    field :errors, list_of(:order_error)
  end # end of delete result

  # orders queries
  object :orders_queries do
    @desc "Get order returns an order specified by a given id"
    field :get_order, non_null(:order_result) do
      arg :order_id, non_null(:id)

      resolve(&Resolver.get_order/3)
    end # end of get_order

    @desc "Get Order bids returns the bids for a given order"
    field :get_order_bids, non_null(list_of(:bid)) do
      arg :order_id, non_null(:id)

      resolve(&Resolver.get_order_bids/3)
    end # end of get_order_bids

    @desc "Get Order proposal returns the proposals for a given order"
    field :get_order_bids, non_null(list_of(:proposal)) do
      arg :order_id, non_null(:id)

      resolve(&Resolver.get_order_proposal/3)
  end # end of the orders_queries

  # orders mutations
  object :orders_mutations do
    @desc "Create order creates a new order and returns the order"
    field :create_order, non_null(:order_result) do
      arg :input, non_null(:order_input)

      resolve(&Resolver.create_order/3)
    end # end of create order

    @desc "Update order updates the order overview and returns the order"
    field :update_order_service, non_null(:order_result) do
      arg :order_id, non_null(:id)
      arg :input, non_null(:order_input)

      resolve(&Resolver.update_order/3)
    end # end of update order

    @desc "Update order details updates the details of an order and returns the order"
    field :update_order_details, non_null(:order_result) do
      arg :order_id, non_null(:id)
      arg :input, non_null(:order_details_input)

      resolve(&Resolver.update_order_details/3)
    end # end of update_order_details

    @desc "Update order payment updates the payment information of an order and returns the order"
    field :update_order_payment, non_null(:order_result) do
      arg :order_id, non_null(:id)
      arg :input, non_null(:order_payment_input)

      resolve(&Resolver.update_order_payment/3)
    end # end of update order payment

    @desc "Update order description updates the description of an order and returns the order"
    field :update_order_description, non_null(:order_result) do
      arg :order_id, non_null(:id)
      arg :description, non_null(:string)

      resolve(&Resolver.update_order_description/3)
    end # end of update order description

    @desc "Delete order deletes an order and returns a confirmation message"
    field :delete_order, non_null(:delete_error) do
      field :order_id, non_null(:id)

      resolve(&Resolver.delete_order/3)
    end # end of delete order

    @desc "Cancel order cancels and order and returns the cancelled order"
    field :cancel_order, non_null(:order_result) do
      arg :order_id, non_null(:string)
    end # end of cancel order
    
  end # end of the orders_mutations
end # end of the orders type module
