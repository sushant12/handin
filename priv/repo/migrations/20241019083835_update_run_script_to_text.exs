defmodule Handin.Repo.Migrations.UpdateRunScriptToText do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      modify :run_script, :text
    end
  end
end
