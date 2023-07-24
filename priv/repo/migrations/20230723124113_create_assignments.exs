defmodule Handin.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add :name, :string
      add :total_marks, :integer
      add :start_date, :utc_datetime
      add :due_date, :utc_datetime
      add :cutoff_date, :utc_datetime
      add :max_attempts, :integer
      add :penalty_per_day, :float
      add :module_id, references(:module, on_delete: :delete_all)

      timestamps()
    end

    create index(:assignments, [:module_id])
  end
end
