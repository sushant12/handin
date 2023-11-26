defmodule Handin.Repo.Migrations.AlterReferencesForBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      remove :assignment_test_id
      add :assignment_id, references(:assignments, type: :uuid, on_delete: :delete_all)
    end

    create index(:builds, [:assignment_id])
  end
end
