defmodule Wynix.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :full_name, :string, null: false
      add :emails, {:array, :string}, default: []
      add :phones, {:array, :string}, default: []
      add :banking, :map, null: true
      add :loaction, :map, null: true
      add :mpesa_number, :string, null: true
      add :payoneer, :string, null: true
      add :paypal, :string, null: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    # unique index for the mpesa_number, payoneer, paypal
    create unique_index(:accounts, [:mpesa_number])
    create unique_index(:accounts, [:payoneer])
    create unique_index(:accounts, [:paypal])

    # index on the full name
    create index(:Accounts, [:full_name])

  end

end # end of migration module
