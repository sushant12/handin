defmodule Handin.Repo.Migrations.CreateUsersRolesTable do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :module_id, references(:modules, on_delete: :delete_all, type: :uuid)
      add :role_id, references(:roles, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:users_roles, [:user_id, :role_id, :module_id])
  end
end
