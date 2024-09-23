defmodule Handin.Repo.Migrations.DropUniversities do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :university_id
    end

    drop table(:universities)
  end
end
