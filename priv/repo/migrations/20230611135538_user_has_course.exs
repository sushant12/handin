defmodule Handin.Repo.Migrations.UserHasCourse do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :course_id, references(:course, on_delete: :delete_all)
    end
  end
end
