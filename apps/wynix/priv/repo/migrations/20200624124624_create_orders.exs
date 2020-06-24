defmodule Wynix.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order_code, :string, null: false
      add :order_category, :string, null: false
      add :order_type, :string, null: false
      add :order_length, :string, null: true
      add :bid_deadline, :date
      add :proposal_required, :boolean, default: false, null: false
      add :payable_amount, :string
      add :payment_at, :string
      add :description, :text, null: true
      add :contractors_needed, :integer, default: 1
      add :status, :string, default: "Unpublished"

      add :assignee_id, references(:practises, on_delete: :nothing, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create unique_index(:orders, [:order_code])
    create index(:orders, [:assignee_id])
    create index(:orders, [:account_id])
    create index(:orders, [:bid_deadline])
    create index(:orders, [:order_category])
    create index(:orders, [:order_type])
    create index(:orders, [:status])

  end
end
