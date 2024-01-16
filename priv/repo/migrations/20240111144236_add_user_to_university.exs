defmodule Handin.Repo.Migrations.AddUserToUniversity do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :university_id, references(:universities, type: :uuid)
    end

    create index(:users, [:university_id])
  end
end
