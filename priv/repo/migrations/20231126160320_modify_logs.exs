defmodule Handin.Repo.Migrations.ModifyLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :assignment_test_id, references(:assignment_tests, type: :uuid, on_delete: :delete_all)
    end

    rename table(:logs), :description, to: :output
  end
end
