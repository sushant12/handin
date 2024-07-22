defmodule Handin.Repo.Migrations.AlterAssignmentTestCustomTest do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      modify :custom_test, :text
    end
  end
end
