defmodule Handin.Modules.Module do
  use Handin.Schema
  import Ecto.Changeset
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesUsers
  alias Handin.Assignments.Assignment
  alias Handin.Modules.ModulesInvitations
  @type t :: %__MODULE__{}

  schema "module" do
    field :name, :string
    field :code, :string
    field :term, :string
    field :archived, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :assignments_count, :integer, virtual: true
    field :students_count, :integer, virtual: true
    has_many :invitations, ModulesInvitations
    has_many :assignments, Assignment
    many_to_many :users, User, join_through: ModulesUsers

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name, :code, :term, :archived])
    |> validate_required([:name, :code, :term])
  end
end
