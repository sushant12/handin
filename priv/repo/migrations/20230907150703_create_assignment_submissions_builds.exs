defmodule Handin.Repo.Migrations.CreateAssignmentSubmissionsBuilds do
  use Ecto.Migration

  def change do
    create table(:assignment_submissions_builds, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :assignment_submission_id,
          references(:assignment_submissions, on_delete: :delete_all, type: :uuid)

      add :build_id, references(:builds, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:assignment_submissions_builds, [:assignment_submission_id, :build_id])
  end
end
