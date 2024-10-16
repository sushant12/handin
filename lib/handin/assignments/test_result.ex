defmodule Handin.Assignments.TestResult do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Assignments.Build
  alias Handin.Accounts.User
  alias Handin.Assignments.AssignmentTest

  schema "test_results" do
    field :state, Ecto.Enum, values: [:pass, :fail]
    field :output, :string

    belongs_to :assignment_test, AssignmentTest
    belongs_to :user, User
    belongs_to :build, Build

    timestamps(type: :utc_datetime)
  end

  @attrs [:state, :assignment_test_id, :user_id, :build_id, :output]

  @req_attrs [:state, :assignment_test_id, :user_id, :build_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @attrs)
    |> validate_required(@req_attrs)
  end
end
