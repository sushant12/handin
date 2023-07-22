defmodule Handin.Repo.Migrations.CreateUniversities do
  use Ecto.Migration

  def change do
    create table(:universities) do
      add :name, :string
      add :config, :map

      timestamps()
    end
  end
end
