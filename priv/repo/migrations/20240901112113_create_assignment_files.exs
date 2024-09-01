defmodule Handin.Repo.Migrations.CreateAssignmentFiles do
  use Ecto.Migration

  def change do
    create table(:assignment_files) do
      add :file, :string
      add :file_type, :string
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:assignment_files, [:assignment_id])
  end
end
