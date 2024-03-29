defmodule Handin.Repo.Migrations.CreateModule do
  use Ecto.Migration

  def change do
    create table(:module, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :code, :string
      add :deleted_at, :utc_datetime
      timestamps()
    end
  end
end
