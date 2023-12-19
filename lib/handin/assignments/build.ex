defmodule Handin.Assignments.Build do
  use Handin.Schema

  import Ecto.Changeset

  alias Handin.Assignments.{Assignment, TestResult, Log, RunScriptResult}
  alias Handin.Accounts.User
  @type t :: %__MODULE__{}
  schema "builds" do
    field :machine_id, :string
    field :status, Ecto.Enum, values: [:running, :failed, :completed]
    belongs_to :assignment, Assignment
    has_many :logs, Log, on_delete: :delete_all
    has_many :test_results, TestResult
    has_one :run_script_result, RunScriptResult
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @attrs [:machine_id, :assignment_id, :status, :user_id]
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:assignment_id, :status, :user_id])
    |> validate_required([:assignment_id, :status, :user_id])
  end

  def update_changeset(build, attrs) do
    build
    |> cast(attrs, @attrs)
  end
end
