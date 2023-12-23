defmodule Handin.Repo.Migrations.AddUserIdidToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
    end

    create index(:builds, [:user_id])
  end
end
