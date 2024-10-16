defmodule Handin.Repo.Migrations.RemoveCommandAndExpectedOutputFromLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      remove :expected_output
      remove :command
      remove :assignment_test_id
    end
  end
end
