defmodule Wynix.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :email, :string, null:false
      add :password_hash, :string, null: false
      add :is_active, :boolean, default: false, null: false
      add :is_suspended, :boolean, default: false, null: false
      add :account_type, :string
      add :token, :string, null: true

      timestamps()
    end

    # unique index for the username and the email
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])

    # index for the is_active and account type and is_suspended
    create index(:users, [:is_active])
    create index(:users, [:is_suspended])
    create index(:users, [:account_type])

  end # end of the change function

end # end of the module
