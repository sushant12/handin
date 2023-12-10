defmodule Handin.Repo.Migrations.CreateTestResults do
  use Ecto.Migration

  def change do
    create table(:test_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :build_id, references(:builds, type: :uuid, on_delete: :nothing)
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :nothing)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :state, :string

      timestamps()
    end

    create unique_index(:test_results, [:build_id, :assignment_test_id])
  end
end
