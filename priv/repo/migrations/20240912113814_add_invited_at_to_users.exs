defmodule Handin.Repo.Migrations.AddInvitedAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :invited_at, :naive_datetime
    end
  end
end
