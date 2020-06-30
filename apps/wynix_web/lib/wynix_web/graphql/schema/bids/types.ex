defmodule WynixWeb.Schema.Types.Bids do
  @moduledoc """
    Defines the graphql schema types for a bid
  """
  use Absinthe.Schema.Notation
  alias WynixWeb.Schema.Bids.Resolver

  # bid object
  object :bid do
    field :id, non_null(:id)
    field :asking_amount, non_null(:decimal)
    field :deposit_amount, :decimal
    field :practise_id, non_null(:id)
    field :owner_name, non_null(:string)
  end # end of bid object

  object :bid_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end # end of bid_error

  # bid result
  object :bid_result do
    field :bid, :bid
    field :errors, list_of(:bid_error)
  end # end of the bid_result

  # input for creating a bid
  object_input :bid_input do
    field :asking_amount, non_null(:decimal)
    field :deposit_amount, non_null(:decimal)
  end # end of the bid input

  # bid result
  object :bid_succes_result do
    field :message, non_null(:string)
  end # end of bid result

  # bid mutations
  object :bid_mutations do
    @desc "Place bid creates a bid for a given order and returns the bid"
    field :place_bid, non_null(:bid_result) do
      arg :order_id, non_null(:id)
      arg :practise_id, non_null(:id)
      arg :practise_name, non_null(:string)
      arg :order_input, non_null(:bid_input)

      resolve(&Resolver.place_bid/3)
    end # end of place bid

    @desc "Reject bid rejects a bid and returns ok"
    field :reject_bid, non_null(:bid_success_message) do
      arg :bid_id, non_null(:id)

      resolve(&Resolver.reject_bid/3)
    end # end of reject_bid
  end # end of bid_mutations
end # end of the bid type
