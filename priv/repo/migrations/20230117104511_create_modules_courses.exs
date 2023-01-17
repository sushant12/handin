defmodule Handin.Repo.Migrations.CreateModulesCourses do
  use Ecto.Migration

  def change do
    create table(:modules_courses, primary_key: false) do
      add :module_id, references(:modules)
      add :course_id, references(:courses)
    end
  end
end
