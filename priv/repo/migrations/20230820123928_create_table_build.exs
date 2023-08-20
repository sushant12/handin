defmodule Handin.Repo.Migrations.CreateTableBuild do
  use Ecto.Migration

  def change do
    create table(:builds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :machine_id, :string
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
