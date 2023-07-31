defmodule Handin.Accounts.Role do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Accounts.{User, UsersRoles}

  schema "roles" do
    field :name, :string

    many_to_many :users, User, join_through: UsersRoles

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
