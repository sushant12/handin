defmodule Handin.Repo.Migrations.CreateProgrammingLanguages do
  use Ecto.Migration

  def change do
    create table(:programming_languages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :docker_file_url, :string

      timestamps()
    end

    alter table(:assignments) do
      add :programming_language_id, references(:programming_languages, type: :uuid)
    end

    create index(:assignments, [:programming_language_id])
  end
end
