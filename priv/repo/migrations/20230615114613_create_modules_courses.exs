defmodule Handin.Repo.Migrations.CreateModulesCourses do
  use Ecto.Migration

  def change do
    create table(:modules_courses) do
      add :module_id, references(:module, on_delete: :delete_all)
      add :course_id, references(:course, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:modules_courses, [:module_id, :course_id])
  end
end
