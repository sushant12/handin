defmodule Handin.Repo.Migrations.CreateTestSupportFiles do
  use Ecto.Migration

  def change do
    create table(:test_support_files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :file, :string
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
