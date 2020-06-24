defmodule Wynix.Repo.Migrations.CreateTokenHistories do
  use Ecto.Migration

  def change do
    create table(:token_histories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token_type, :string
      add :order_code, :string
      add :token_code, :string
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    # index on the account id
    create index(:token_histories, [:account_id])
    # index for the token code
    create uniqe_index(:token_histories, [:token_code])
    # index on the inserted at
    create index(:token_histories, [:inserted_at])
    # index for the account id
    create index(:account_id, [:account_id])

  end

end # end of the migration for the token histories
