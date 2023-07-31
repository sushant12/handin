defmodule Handin.Repo.Migrations.CreateUsersRolesTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    create table(:users_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :role_id, references(:roles, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:users_roles, [:user_id, :role_id])

    execute "INSERT INTO roles(id, name, inserted_at, updated_at) VALUES (gen_random_uuid(), 'lecturer', now(), now()), (gen_random_uuid(),'teaching_assistant', now(), now()), (gen_random_uuid(),'student', now(), now())"
  end
end
