defmodule Handin.Repo.Migrations.AddTotalPoints do
  use Ecto.Migration

  def change do
    alter table(:assignment_submissions) do
      add :total_points, :float
    end
  end
end
