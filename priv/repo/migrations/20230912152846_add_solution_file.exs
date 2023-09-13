defmodule Handin.Repo.Migrations.AddSolutionFile do
  use Ecto.Migration

  def change do
    alter table(:test_support_files) do
      add :solution_file, :boolean, default: false
    end
  end
end
