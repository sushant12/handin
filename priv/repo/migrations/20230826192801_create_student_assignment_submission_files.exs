defmodule Handin.Repo.Migrations.CreateStudentAssignmentSubmissionFiles do
  use Ecto.Migration

  def change do
    create table(:student_assignment_submission_files, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :student_assignment_submission_id,
          references(:student_assignment_submissions, type: :uuid)

      add :file, :string
      timestamps(type: :utc_datetime)
    end

    create index(:student_assignment_submission_files, [:student_assignment_submission_id])
  end
end
