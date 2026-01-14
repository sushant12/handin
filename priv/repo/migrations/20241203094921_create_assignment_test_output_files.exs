defmodule Handin.Repo.Migrations.CreateAssignmentTestOutputFiles do
  use Ecto.Migration

  def change do
    create table(:assignment_test_output_files, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :delete_all)

      add :assignment_submission_id,
          references(:assignment_submissions, type: :binary_id, on_delete: :delete_all)

      add :file, :string

      timestamps()
    end

    create index(:assignment_test_output_files, [:assignment_test_id])
    create index(:assignment_test_output_files, [:assignment_submission_id])
  end
end
