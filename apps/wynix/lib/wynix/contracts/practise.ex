defmodule Wynix.Contracts.Practise do
  @moduledoc """
    Represents the practise that has been assigned the order
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "practises" do
    field :practise_name, :string
    field :practise_code, :string

    # can have many bids
    has_many :bids, Wynix.Contracts.Bid
    # belong to one order
    belongs_to :order, Wynix.Contracts.Order
  end # end of the practises schema
end # end of the assignee module
