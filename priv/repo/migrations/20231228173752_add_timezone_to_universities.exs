defmodule Handin.Repo.Migrations.AddTimezoneToUniversities do
  use Ecto.Migration

  def change do
    alter table(:universities) do
      add :timezone, :string
    end
  end
end
