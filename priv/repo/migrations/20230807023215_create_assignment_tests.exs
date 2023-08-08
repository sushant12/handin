defmodule Handin.Repo.Migrations.CreateAssignmentTests do
  use Ecto.Migration

  def change do
    create table(:assignment_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :marks, :float
      add :command, :string
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:assignment_tests, [:assignment_id])
  end
end
