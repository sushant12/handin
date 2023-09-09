defmodule Handin.Repo.Migrations.AddDeletedAtToAssignmentSubmissionBuild do
  use Ecto.Migration

  def change do
    alter table(:assignment_submissions_builds) do
      add :deleted_at, :utc_datetime
    end
  end
end
