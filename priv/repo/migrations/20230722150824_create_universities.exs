defmodule Handin.Repo.Migrations.CreateUniversities do
  use Ecto.Migration

  def change do
    create table(:universities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :student_email_regex, :string

      timestamps()
    end

    create unique_index(:universities, [:name])
  end
end
