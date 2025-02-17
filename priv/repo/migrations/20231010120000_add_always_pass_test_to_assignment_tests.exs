defmodule Handin.Repo.Migrations.AddAlwaysPassTestToAssignmentTests do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      add :always_pass_test, :boolean, default: false
    end
  end
end
