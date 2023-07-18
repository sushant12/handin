defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.Accounts.User
  alias Handin.ModulesStudents

  schema "module" do
    field :name, :string

    has_one :teacher, User
    many_to_many :students, User, join_through: ModulesStudents

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
