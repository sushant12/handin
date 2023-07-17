defmodule Handin.Accounts.UsersRoles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_roles" do
    belongs_to :users, Handin.Accounts.User
    belongs_to :roles, Handin.Accounts.Role

    timestamps()
  end

  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role_id, :user_id])
    |> validate_required([:role_id, :user_id])
  end
end
