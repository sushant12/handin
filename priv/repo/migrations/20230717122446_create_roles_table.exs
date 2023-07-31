defmodule Handin.Repo.Migrations.CreateRolesTable do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:roles, [:name])
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    execute "INSERT INTO roles(id, name, inserted_at, updated_at) VALUES (gen_random_uuid(), 'Lecturer', now(), now()), (gen_random_uuid(),'Teaching Assistant', now(), now()), (gen_random_uuid(),'Student', now(), now())"
  end
end
