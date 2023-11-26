defmodule Handin.Repo.Migrations.ModifyAssignments do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      add :run_script, :string
      add :attempt_marks, :int
    end
  end
end
