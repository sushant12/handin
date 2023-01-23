defmodule Handin.Repo.Migrations.ModuleHasTeacher do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :module_id, references(:modules, on_delete: :delete_all)
    end

    # alter table(:modules) do
    # add :teacher_id, references(:users, on_delete: :delete_all)
    # end

    create unique_index(:modules, [:name])
  end
end
