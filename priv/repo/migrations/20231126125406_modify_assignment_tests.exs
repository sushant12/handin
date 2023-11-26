defmodule Handin.Repo.Migrations.ModifyAssignmentTests do
  use Ecto.Migration

  def change do
    alter table(:assignment_tests) do
      remove :marks
      add :points_on_pass, :float
      add :points_on_fail, :float
      add :commands, :text
      add :expected_output_type, :string
      add :expected_output_text, :text
      add :expected_output_file, :text
      add :ttl, :integer
    end
  end
end
