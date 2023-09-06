defmodule Handin.Repo.Migrations.CreateAssignmentSubmissionTests do
  use Ecto.Migration

  def change do
    create table(:assignment_submission_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :failed_at, :utc_datetime

      add :assignment_submission_id,
          references(:assignment_submissions, type: :uuid)

      add :assignment_test_id, references(:assignment_tests, type: :uuid)
      timestamps(type: :utc_datetime)
    end

    create index(:assignment_submission_tests, [:assignment_submission_id])
    create index(:assignment_submission_tests, [:assignment_test_id])
  end
end
