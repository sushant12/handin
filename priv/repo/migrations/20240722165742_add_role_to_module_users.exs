defmodule Handin.Repo.Migrations.AddRoleToModuleUsers do
  use Ecto.Migration

  def change do
    alter table(:modules_users) do
      add :role, :string, default: "student"
    end
  end
end
