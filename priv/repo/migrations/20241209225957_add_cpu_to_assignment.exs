defmodule Handin.Repo.Migrations.AddCpuToAssignment do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      add :cpu, :integer, default: 1
      add :memory, :integer, default: 256
    end
  end
end
