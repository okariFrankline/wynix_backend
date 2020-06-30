defmodule Wynix.Contracts.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Generator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :amount, :float, virtual: true
    field :bid_deadline, :date
    field :contractors_needed, :integer, default: 1
    field :currency, :string, virtual: true
    field :description, :string
    field :order_category, :string
    field :order_code, :string
    field :order_length, :string
    field :order_type, :string
    field :payable_amount, :string
    field :payment_at, :string
    field :proposal_required, :boolean, default: false
    field :status, :string, default: "Unpublished"
    # owner
    belongs_to :account, Wynix.Contracts.Order
    # assignee
    has_many :practise, Wynix.Contracts.Order
    # bids
    has_many :bids, Wynix.Contracts.Bid

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :order_code,
      :order_category,
      :order_type,
      :order_length,
      :bid_deadline,
      :proposal_required,
      :payable_amount,
      :payment_at,
      :description,
      :contractors_needed,
      :status
    ])
  end

  @doc false
  def creation_changeset(order, attrs) do
    changeset(order, attrs)
    |> validate_required([
      :order_category,
      :order_type,
      :account_id
    ])
    |> add_order_code()
    |> foreign_key_constraint(:account_id)
  end # end of creation_changeset/2

  @doc false
  def update_description_changeset(order, attrs) do
    changeset(order, attrs)
    |> validate_required([
      :description
    ])
  end # end of update_bio_changeset/2

  @doc false
  def add_payment_changeset(order, attrs) do
    changeset(order, attrs)
    |> cast(attrs, [
      :currency,
      :amount
    ])
    |> add_payable_amount()
  end

  @doc false
  def add_service_changeset(order, attrs) do
    changeset(order, attrs)
    |> validate_required([
      :order_category,
      :order_type
    ])
  end # end of add_service_changeset/2

  # add order code adds the order code to the order
  defp add_order_code(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:order_code, Generator.generate())
  end # end of add_order_code/1
  defp add_order_code(changeset), do: changeset

  # add payable amount adds the payable amount to the changeset by combining the currency and the amount
  defp add_payable_amount(%Ecto.Changeset{valid?: true, changes: %{currency: currency, amount: amount}} = changeset) do
    payable_amount = "#{currency} #{amount}"
    changeset |> put_change(:payable_amount, payable_amount)
  end # end of add_payable_amount/2
  defp add_payable_amount(changeset), do: changeset

end # end of Order module
