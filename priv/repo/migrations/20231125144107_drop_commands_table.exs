defmodule Handin.Repo.Migrations.DropCommandsTable do
  use Ecto.Migration

  def change do
    drop index(:logs, [:command_id, :build_id])
    alter table(:logs) do
      remove :command_id
    end

    drop table(:commands)
  end
end
