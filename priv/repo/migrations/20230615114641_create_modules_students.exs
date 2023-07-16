defmodule Handin.Repo.Migrations.CreateModulesStudents do
  use Ecto.Migration

  def change do
    create table(:modules_students) do
      add :module_id, references(:module, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:modules_students, [:module_id, :user_id])
  end
end
