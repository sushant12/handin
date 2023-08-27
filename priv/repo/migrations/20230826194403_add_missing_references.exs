defmodule Handin.Repo.Migrations.AddMissingReferences do
  use Ecto.Migration

  def change do
    create index(:test_support_files, [:assignment_test_id])
    create index(:commands, [:assignment_test_id])
    create index(:builds, [:assignment_test_id])
    create index(:logs, [:build_id])
  end
end
