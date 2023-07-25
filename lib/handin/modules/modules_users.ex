defmodule Handin.Modules.ModulesUsers do
  use Handin.Schema
  import Ecto.Changeset

  schema "modules_users" do
    belongs_to :module, Handin.Modules.Module
    belongs_to :user, Handin.Accounts.User

    timestamps()
  end

  def changeset(module_user, attrs) do
    module_user
    |> cast(attrs, [:module_id, :user_id])
    |> validate_required([:module_id, :user_id])
  end
end
