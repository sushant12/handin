defmodule Handin.Repo.Migrations.AddTimeout do
  use Ecto.Migration

  def change do
    alter table(:commands) do
      add :timeout, :integer, default: 0
    end
  end
end
