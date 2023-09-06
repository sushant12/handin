defmodule Handin.Repo.Migrations.CreateAssignmentSubmissionFiles do
  use Ecto.Migration

  def change do
    create table(:assignment_submission_files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :file, :string

      add :assignment_submission_id,
          references(:assignment_submissions, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:assignment_submission_files, [:assignment_submission_id])
  end
end
