defmodule Handin.Repo.Migrations.CreateIndexModulesCourses do
  use Ecto.Migration

  def change do
    create unique_index(:modules_courses, [:module_id, :course_id])
  end
end
