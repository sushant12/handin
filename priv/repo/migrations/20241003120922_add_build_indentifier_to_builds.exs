defmodule Handin.Repo.Migrations.AddBuildIndentifierToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :build_identifier, :binary_id
    end

    create unique_index(:builds, [:build_identifier, :id])
  end
end
