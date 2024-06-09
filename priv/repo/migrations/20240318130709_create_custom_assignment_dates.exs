defmodule Handin.Repo.Migrations.CreateCustomAssignmentDates do
  use Ecto.Migration

  def change do
    create table(:custom_assignment_dates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :delete_all)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)

      add :start_date, :naive_datetime
      add :due_date, :naive_datetime
      add :enable_cutoff_date, :boolean
      add :cutoff_date, :naive_datetime

      timestamps()
    end

    create index(:custom_assignment_dates, [:assignment_id])
    create index(:custom_assignment_dates, [:user_id])
    create unique_index(:custom_assignment_dates, [:assignment_id, :user_id])
  end
end
