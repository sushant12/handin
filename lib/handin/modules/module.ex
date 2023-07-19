defmodule Handin.Modules.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.Accounts.User
  alias Handin.ModulesStudents

  schema "module" do
    field :name, :string
    field :code, :string
    field :deleted_at, :utc_datetime

    has_one :lecturer, User
    many_to_many :students, User, join_through: ModulesStudents

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint([:name, :code])
  end
end
