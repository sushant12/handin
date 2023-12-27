defmodule Handin.Repo.Migrations.AlterUtcDateTimeToNaive do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      modify :start_date, :naive_datetime
      modify :due_date, :naive_datetime
      modify :cutoff_date, :naive_datetime
    end
  end
end
