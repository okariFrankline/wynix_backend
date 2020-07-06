defmodule Wynix.Repo.Migrations.CreatePractises do
  use Ecto.Migration

  def change do
    create table(:practises, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practise_code, :string, null: false
      add :rank, :string, null: false, default: "Silver"
      add :practise_type, :string, null: false, default: "Freelance Practise"
      add :rating, :float, null: false, default: 1
      add :bio, :text, null: true
      add :countries, {:array, :string}, default: []
      add :cities, {:array, :string}, default: []
      add :skills, {:array, :string}, default: []
      add :practise_name, :string, null: false
      add :operate_outside_base_location, :boolean, default: false
      add :professional_level, :string, null: true, default: "Amateur"

      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:practises, [:practise_name])
    create unique_index(:practises, [:practise_code])
    create index(:practises, [:practise_type])
    create index(:practises, [:account_id])
    create index(:practises, [:professional_level])
    create index(:practises, [:rank])
  end

end # end of the module definition
