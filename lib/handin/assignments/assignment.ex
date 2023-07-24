defmodule Handin.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Handin.Modules.Module

  schema "assignments" do
    field :name, :string
    field :max_attempts, :integer
    field :total_marks, :integer
    field :start_date, :utc_datetime
    field :due_date, :utc_datetime
    field :cutoff_date, :utc_datetime
    field :penalty_per_day, :float

    belongs_to :module, Module

    timestamps()
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [
      :name,
      :total_marks,
      :start_date,
      :due_date,
      :cutoff_date,
      :max_attempts,
      :penalty_per_day
    ])
    |> validate_required([
      :name,
      :total_marks,
      :start_date,
      :due_date,
      :cutoff_date,
      :max_attempts,
      :penalty_per_day
    ])
  end
end
