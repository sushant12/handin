defmodule Handin.Repo.Migrations.AddFieldsToAssignment do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      add :enable_cutoff_date, :boolean
      add :enable_attempt_marks, :boolean
      add :enable_penalty_per_day, :boolean
      add :enable_max_attemps, :boolean
      add :enable_total_marks, :boolean
      add :enable_test_output, :boolean
    end
  end
end
