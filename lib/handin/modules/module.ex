defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesUsers
  alias Handin.Assignments.Assignment

  schema "module" do
    field :name, :string
    field :code, :string
    field :deleted_at, :utc_datetime

    has_many :assignments, Assignment
    many_to_many :users, User, join_through: ModulesUsers

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
  end
end
