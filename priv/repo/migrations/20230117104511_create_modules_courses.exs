defmodule Handin.Repo.Migrations.CreateModulesCourses do
  use Ecto.Migration

  def change do
    create table(:modules_courses) do
      add :module_id, references(:modules, on_delete: :delete_all)
      add :course_id, references(:courses, on_delete: :delete_all)

      timestamps()
    end
  end
end
