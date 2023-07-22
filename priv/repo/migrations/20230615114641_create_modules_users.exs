defmodule Handin.Repo.Migrations.CreateModulesUsers do
  use Ecto.Migration

  def change do
    create table(:modules_users) do
      add :module_id, references(:module, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:modules_users, [:module_id, :user_id])
  end
end
