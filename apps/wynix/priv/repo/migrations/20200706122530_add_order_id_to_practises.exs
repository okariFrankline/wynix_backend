defmodule Wynix.Repo.Migrations.AddOrderIdToPractises do
  use Ecto.Migration

  def change do
    alter table(:practises) do
      add :order_id, references(:orders, type: :binary_id, on_delete: :nothing)
    end # end of alter table

    create index(:practises, [:order_id])
  end
end
