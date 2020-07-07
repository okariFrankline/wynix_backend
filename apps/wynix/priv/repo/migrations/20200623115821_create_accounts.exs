defmodule Wynix.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :account_type, :string, null: false, default: "Client Account"
      add :is_suspended, :boolean, default: false, null: false
      add :account_code, :string, null: false
      add :id, :binary_id, primary_key: true
      add :account_holder, :string, null: false
      add :emails, {:array, :string}, default: []
      add :phones, {:array, :string}, default: []
      add :mpesa_number, :string, null: true
      add :payoneer, :string, null: true
      add :paypal, :string, null: true
      add :bid_tokens, :integer, default: 10
      add :publish_tokens, :integer, default: 5
      # banking information
      add :bank_name, :string, null: true
      add :bank_branch, :string, null: true
      add :account_number, :string, null: true
      # location information
      add :country, :string, null: true
      add :city, :string, null: true
      add :physical_address, :string, null: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    # unique index for the mpesa_number, payoneer, paypal
    create unique_index(:accounts, [:mpesa_number])
    create unique_index(:accounts, [:payoneer])
    create unique_index(:accounts, [:account_code])
    create unique_index(:accounts, [:account_number])
    create unique_index(:accounts, [:paypal])
    create index(:accounts, [:user_id])
    # index on the full name
    create index(:accounts, [:account_holder])

  end

end # end of migration module
