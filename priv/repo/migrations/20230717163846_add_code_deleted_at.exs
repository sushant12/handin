defmodule Handin.Repo.Migrations.AddCodeDeletedAt do
  use Ecto.Migration

  def change do
    alter table(:module) do
      add :code, :string
      add :deleted_at, :utc_datetime
    end
  end
end
