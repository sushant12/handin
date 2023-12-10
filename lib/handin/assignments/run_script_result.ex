defmodule Handin.Assignments.RunScriptResult do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.Build
  alias Handin.Accounts.User
  alias Handin.Assignments.Assignment

  schema "test_results" do
    field :state, Ecto.Enum, values: [:pass, :fail]

    belongs_to :assignment, Assignment
    belongs_to :user, User
    belongs_to :build, Build

    timestamps(type: :utc_datetime)
  end

  @attrs [:state, :assignment_id, :user_id, :build_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
