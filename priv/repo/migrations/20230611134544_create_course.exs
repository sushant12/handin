defmodule Handin.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table(:course) do
      add :code, :integer
      add :name, :string

      timestamps()
    end
  end
end
