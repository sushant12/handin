defmodule Handin.Repo.Migrations.AddTestSleepDurationToAssignmentTest do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      add :enable_test_sleep, :boolean, default: false
      add :test_sleep_duration, :integer
    end
  end
end
