defmodule Handin.Repo.Migrations.AlterTestResults do
  use Ecto.Migration

  def change do
    alter table(:test_results) do
      modify :assignment_test_id,
             references(:assignment_tests, type: :uuid, on_delete: :delete_all),
             from: references(:assignment_tests, on_delete: :nothing)
    end
  end
end
