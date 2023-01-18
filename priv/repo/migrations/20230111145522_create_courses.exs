defmodule Handin.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :code, :integer

      timestamps()
    end
  end
end
