defmodule Handin.Repo.Migrations.CreateRunScriptResults do
  use Ecto.Migration

  def change do
    create table(:run_script_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :build_id, references(:builds, type: :uuid, on_delete: :nothing)
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :nothing)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :state, :string

      timestamps()
    end

    create unique_index(:run_script_results, [:build_id, :assignment_id])
  end
end
