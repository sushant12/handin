defmodule Handin.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :total_marks, :integer
      add :start_date, :utc_datetime
      add :due_date, :utc_datetime
      add :cutoff_date, :utc_datetime
      add :max_attempts, :integer
      add :penalty_per_day, :float
      add :module_id, references(:module, type: :uuid)

      timestamps()
    end

    create index(:assignments, [:module_id])
  end
end
