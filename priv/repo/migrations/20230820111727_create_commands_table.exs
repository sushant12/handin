defmodule Handin.Repo.Migrations.CreateCommandsTable do
  use Ecto.Migration

  def change do
    create table(:commands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :command, :text
      add :fail, :boolean
      add :expected_output, :text
      add :response, :text

      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
