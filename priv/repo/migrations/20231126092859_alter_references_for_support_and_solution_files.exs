defmodule Handin.Repo.Migrations.AlterReferencesForSupportAndSolutionFiles do
  use Ecto.Migration

  def change do
    rename table(:test_support_files), to: table(:support_files)

    alter table(:support_files) do
      remove :assignment_test_id
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :nothing)
    end

    alter table(:solution_files) do
      remove :assignment_test_id
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :nothing)
    end

    create index(:support_files, [:assignment_id])
    create index(:solution_files, [:assignment_id])
  end
end
