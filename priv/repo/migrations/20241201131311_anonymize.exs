defmodule Handin.Repo.Migrations.Anonymize do
  use Ecto.Migration

  def change do
    execute """
      CREATE EXTENSION IF NOT EXISTS anon;
    """
  end
end
