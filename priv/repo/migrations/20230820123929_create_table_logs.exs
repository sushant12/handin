defmodule Handin.Repo.Migrations.CreateTableLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :build_id, references(:builds, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
