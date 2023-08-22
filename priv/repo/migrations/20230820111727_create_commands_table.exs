defmodule Handin.Repo.Migrations.CreateCommandsTable do
  use Ecto.Migration

  def change do
    create table(:commands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :command, :string
      add :fail, :boolean
      add :expected_output, :string
      add :response, :string

      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
