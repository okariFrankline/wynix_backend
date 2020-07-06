defmodule Wynix.Skills.Account do
  @moduledoc """
    Defines the account struct to be used for the relationship with the practise struct
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :account_holder, :string

    has_one :practise, Wynix.Skills.Practise
  end # end of the schema defintion

end # end of the model definition
