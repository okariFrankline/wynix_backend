defmodule Wynix.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :deposit_amount, :float
      add :asking_amount, :float
      add :status, :string
      add :owner_name, :string
      add :bid_code, :string, null: false
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
      add :practise_id, references(:practises, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:bids, [:order_id])
    create index(:bids, [:practise_id])
    create index(:bids, [:bid_code])
  end
end
