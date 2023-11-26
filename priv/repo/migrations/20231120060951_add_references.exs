defmodule Handin.Repo.Migrations.AddReferences do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :command_id, references(:commands, type: :uuid, on_delete: :delete_all)
    end

    alter table(:commands) do
      add :log_id, references(:logs, type: :uuid, on_delete: :delete_all)
    end

    create unique_index(:logs, [
             :command_id,
             :build_id
           ])
  end
end
