defmodule Handin.Repo.Migrations.UserHasCourses do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :course_id, references(:courses, on_delete: :delete_all)
    end
  end
end
