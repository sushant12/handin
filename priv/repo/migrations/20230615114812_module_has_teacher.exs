defmodule Handin.Repo.Migrations.ModuleHasLecturer do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :module_id, references(:module, on_delete: :delete_all)
    end
  end
end
