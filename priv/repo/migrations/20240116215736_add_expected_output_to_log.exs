defmodule Handin.Repo.Migrations.AddExpectedOutputToLog do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :expected_output, :text
    end
  end
end
