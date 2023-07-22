defmodule Handin.Repo.Migrations.CreateRolesTable do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:roles, [:name])
  end
end
