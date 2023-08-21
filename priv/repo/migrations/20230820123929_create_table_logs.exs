defmodule Handin.Repo.Migrations.CreateTableLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string
      add :build_id, references(:builds, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
