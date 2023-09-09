defmodule Handin.Repo.Migrations.AddRetries do
  use Ecto.Migration

  def change do
    alter table(:assignment_submissions) do
      add :retries, :integer
    end
  end
end
