defmodule Handin.Repo.Migrations.CreateModulesInvitations do
  use Ecto.Migration

  def change do
    create table(:modules_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :role, :string
      add :module_id, references(:module, type: :uuid)
    end

    create unique_index(:modules_invitations, [:email, :module_id])
  end
end
