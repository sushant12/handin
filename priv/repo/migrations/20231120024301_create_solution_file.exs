defmodule Handin.Repo.Migrations.CreateSolutionFile do
  use Ecto.Migration

  def change do
    create table(:solution_files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :file, :string
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:solution_files, [:assignment_test_id])
  end
end
