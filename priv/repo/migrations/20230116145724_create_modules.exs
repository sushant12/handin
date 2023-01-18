defmodule Handin.Repo.Migrations.CreateModules do
  use Ecto.Migration

  def change do
    create table(:modules) do
      add :name, :string

      timestamps()
    end
  end
end
