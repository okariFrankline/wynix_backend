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

  # input for creating a bid
  object_input :bid_input do
    field :asking_amount, non_null(:decimal)
    field :deposit_amount, non_null(:decimal)
  end # end of the bid input

  # bid mutations
  object :bid_mutations do
    @desc "Place bid creates a bid for a given order and returns the bid"
    field :place_bid, non_null(:bid) do
      arg :order_id, non_null(:id)
      arg :practise_id, non_null(:id)
      arg :practise_name, non_null(:string)
      arg :order_input, non_null(:bid_input)

      resolve(&Resolver.place_bid/3)
    end # end of place bid
  end # end of bid_mutations
end # end of the bid type
