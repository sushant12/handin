defmodule Handin.Repo.Migrations.CreateModulesStudents do
  use Ecto.Migration

  def change do
    create table(:modules_students) do
      add :module_id, references(:modules)
      add :user_id, references(:users)

      timestamps()
    end

    create unique_index(:modules_students, [:module_id, :user_id])
  end
end
