defmodule Handin.Repo.Migrations.CreateAssignmentSubmissions do
  use Ecto.Migration

  def change do
    create table(:assignment_submissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid)
      add :assignment_id, references(:assignments, type: :uuid)
      add :submitted_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create index(:assignment_submissions, [:assignment_id])
    create index(:assignment_submissions, [:user_id])
    create unique_index(:assignment_submissions, [:user_id, :assignment_id])
  end
end
