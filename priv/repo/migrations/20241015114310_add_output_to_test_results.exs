defmodule Handin.Repo.Migrations.AddOutputToTestResults do
  use Ecto.Migration

  def change do
    alter table(:test_results) do
      add :output, :string
    end
  end
end
