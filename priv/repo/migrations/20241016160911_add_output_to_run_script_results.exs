defmodule Handin.Repo.Migrations.AddOutputToRunScriptResults do
  use Ecto.Migration

  def change do
    alter table(:run_script_results) do
      add :output, :string
    end
  end
end
