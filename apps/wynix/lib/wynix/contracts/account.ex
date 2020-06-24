defmodule Wynix.Contracts.Account do
  @moduledoc """
    Defines the account struct to be used for the relationship with the Order structs
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :owner_name, :string
    # has many orders
    has_many :orders, Wynix.Contracts.Order
    
  end # end of accounts schema

end # end of Contracts.Account
