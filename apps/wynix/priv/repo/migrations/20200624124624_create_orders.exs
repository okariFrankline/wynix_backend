defmodule Wynix.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order_code, :string
      add :order_category, :string
      add :order_type, :string
      add :order_length, :string
      add :bid_deadline, :date
      add :proposal_required, :boolean, default: false, null: false
      add :currency, :string
      add :amount, :float
      add :payment_at, :string
      add :description, :text
      add :contractors_needed, :integer
      add :status, :string

      timestamps()
    end

  end
end
