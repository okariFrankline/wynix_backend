defmodule Wynix.Contracts.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Generator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bids" do
    field :asking_amount, :float
    field :deposit_amount, :float, default: 0.0
    field :owner_name, :string
    field :bid_code, :string
    field :status, :string, default: "Pending"
    # bid for
    belongs_to :order, Wynix.Contracts.Order
    # bid_owner
    belongs_to :practise, Wynix.Contracts.Practise

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [
      :deposit_amount,
      :asking_amount,
      :status,
      :owner_name,
      :order_id,
      :practise_id
    ])
  end

  @spec creation_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def creation_changeset(bid, attrs) do
    changeset(bid, attrs)
    |> validate_required([
      :deposit_amount,
      :asking_amount,
      :owner_name,
      :order_id,
      :practise_id
    ])
    |> insert_code()
  end # end of the creation_changeset

  defp insert_code(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:bid_code, "bid-#{Generator.generate()}")
  end # end of insert_code
  # caled if the changeset is not valid
  defp insert_code(changeset), do: changeset

end # end of Bid module
