defmodule Handin.Repo.Migrations.AlterTimestamps do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      modify :inserted_at, :utc_datetime_usec
      modify :updated_at, :utc_datetime_usec
    end
  end
end
