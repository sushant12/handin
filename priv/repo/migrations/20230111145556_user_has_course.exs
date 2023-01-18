defmodule Handin.Repo.Migrations.UserHasCourses do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :course_id, references(:courses)
    end
  end
end
