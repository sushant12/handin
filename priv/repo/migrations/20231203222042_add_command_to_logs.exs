defmodule Handin.Repo.Migrations.AddCommandToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :command, :string
    end
  end
end
