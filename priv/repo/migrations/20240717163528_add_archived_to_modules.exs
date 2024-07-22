defmodule Handin.Repo.Migrations.AddArchivedToModules do
  use Ecto.Migration

  def change do
    alter table(:module) do
      add :archived, :boolean, default: false
    end
  end
end
