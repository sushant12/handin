defmodule Handin.Repo.Migrations.CreateModuleTas do
  use Ecto.Migration

  def change do
    create table(:module_tas) do
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :module_id, references(:module, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:module_tas, [:user_id])
    create index(:module_tas, [:module_id])
  end
end
