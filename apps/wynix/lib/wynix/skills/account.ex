defmodule Wynix.Skills.Account do
  @moduledoc """
    Defines the account struct to be used for the relationship with the practise struct
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    # email addresses of the practise
    field :emails, {:array, :string}
    # phone numbers of the practise
    field :string, {:array, :string}
    # base location of the practise
    embeds_one :location, Location do
      field :country, :string
      field :city, :string
      field :physical_address, :string
    end
    
    has_one :practise, Wynix.Skills.Practise
  end # end of the schema defintion

end # end of the model definition
