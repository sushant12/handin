defmodule Handin.Repo.Migrations.CreateStudentAssignmentSubmissionTests do
  use Ecto.Migration

  def change do
    create table(:student_assignment_submission_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :student_assignment_submission_id,
          references(:student_assignment_submissions, type: :uuid)

      add :assignment_test_id, references(:assignment_tests, type: :uuid)
      add :failed_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create index(:student_assignment_submission_tests, [:student_assignment_submission_id])
    create index(:student_assignment_submission_tests, [:assignment_test_id])
  end
end
