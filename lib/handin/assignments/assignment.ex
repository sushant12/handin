defmodule Handin.Assignments.Assignment do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Modules.Module
  alias Handin.ProgrammingLanguages.ProgrammingLanguage
  alias Handin.Assignments.{AssignmentTest, Build, SupportFile, SolutionFile}
  alias Handin.AssignmentSubmission.AssignmentSubmission

  schema "assignments" do
    field :name, :string
    field :max_attempts, :integer
    field :total_marks, :integer
    field :start_date, :utc_datetime
    field :due_date, :utc_datetime
    field :cutoff_date, :utc_datetime
    field :penalty_per_day, :float
    field :run_script, :string
    field :attempt_marks, :integer

    belongs_to :module, Module
    belongs_to :programming_language, ProgrammingLanguage, on_replace: :nilify

    has_many :assignment_tests, AssignmentTest
    has_many :assignment_submissions, AssignmentSubmission
    has_many :builds, Build
    has_many :support_files, SupportFile, on_delete: :delete_all
    has_many :solution_files, SolutionFile, on_delete: :delete_all

    timestamps()
  end

  @required_attrs [
    :name,
    :total_marks,
    :start_date,
    :due_date,
    :cutoff_date,
    :max_attempts,
    :penalty_per_day,
    :module_id,
    :programming_language_id,
    :attempt_marks
  ]

  @attrs @required_attrs ++ [:run_script]

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, @attrs)
    |> cast_assoc(:assignment_tests, with: &AssignmentTest.changeset/2)
    |> validate_required(@required_attrs)
    |> validate_number(:max_attempts, greater_than_or_equal_to: 0)
    |> validate_number(:penalty_per_day, greater_than_or_equal_to: 0)
    |> validate_number(:total_marks, greater_than_or_equal_to: 0)
  end
end
