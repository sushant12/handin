defmodule Handin.Modules.ModulesInvitations do
  use Handin.Schema
  import Ecto.Changeset

  schema "modules_invitations" do
    field :email, :string
    field :role, :string

    belongs_to :module, Handin.Modules.Module
    timestamps()
  end

  def changeset(module_invitation, attrs) do
    module_invitation
    |> cast(attrs, [:email, :role])
    |> validate_required([:email, :role])
    |> unique_constraint([:email, :module_id])
  end
end
