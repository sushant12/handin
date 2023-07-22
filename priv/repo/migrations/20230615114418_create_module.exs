defmodule Handin.Repo.Migrations.CreateModule do
  use Ecto.Migration

  def change do
    create table(:module) do
      add :name, :string

      timestamps()
    end
  end
end
