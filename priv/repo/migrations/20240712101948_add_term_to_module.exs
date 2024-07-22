defmodule Handin.Repo.Migrations.AddTermToModule do
  use Ecto.Migration

  def change do
    alter table(:module) do
      add :term, :string
    end

  end
end
