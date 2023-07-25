defmodule Handin.Accounts.UsersRoles do
  use Handin.Schema
  import Ecto.Changeset

  schema "users_roles" do
    belongs_to :user, Handin.Accounts.User
    belongs_to :role, Handin.Accounts.Role

    timestamps()
  end

  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role_id, :user_id])
    |> validate_required([:role_id, :user_id])
  end
end
