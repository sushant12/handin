defmodule Handin.Assignments.Assignment do
  use Handin.Schema
  use Timex

  import Ecto.Changeset
  alias Handin.Modules.Module
  alias Handin.ProgrammingLanguages.ProgrammingLanguage

  alias Handin.Assignments.{
    AssignmentTest,
    Build,
    RunScriptResult,
    CustomAssignmentDate,
    AssignmentFile
  }

  alias Handin.AssignmentSubmission.AssignmentSubmission
  @type t :: %__MODULE__{}
  schema "assignments" do
    field :name, :string
    field :start_date, :naive_datetime
    field :due_date, :naive_datetime
    field :run_script, :string

    field :enable_max_attempts, :boolean, default: false
    field :max_attempts, :integer
    field :enable_total_marks, :boolean, default: false
    field :total_marks, :integer
    field :enable_cutoff_date, :boolean, default: false
    field :cutoff_date, :naive_datetime
    field :enable_penalty_per_day, :boolean, default: false
    field :penalty_per_day, :float
    field :enable_attempt_marks, :boolean, default: false
    field :attempt_marks, :integer
    field :enable_test_output, :boolean, default: false

    belongs_to :module, Module
    belongs_to :programming_language, ProgrammingLanguage, on_replace: :nilify

    has_many :assignment_tests, AssignmentTest,
      on_delete: :delete_all,
      preload_order: [asc: :inserted_at]

    has_many :assignment_submissions, AssignmentSubmission, on_delete: :delete_all
    has_many :builds, Build, preload_order: [asc: :inserted_at]
    has_many :assignment_files, AssignmentFile, on_delete: :delete_all
    has_many :run_script_results, RunScriptResult, on_delete: :delete_all
    has_many :custom_assignment_dates, CustomAssignmentDate, on_delete: :delete_all

    timestamps()
  end

  @required_attrs [
    :name,
    :start_date,
    :due_date,
    :module_id
  ]

  @attrs [
    :name,
    :total_marks,
    :start_date,
    :due_date,
    :cutoff_date,
    :max_attempts,
    :penalty_per_day,
    :module_id,
    :programming_language_id,
    :attempt_marks,
    :run_script,
    :enable_cutoff_date,
    :enable_attempt_marks,
    :enable_penalty_per_day,
    :enable_max_attempts,
    :enable_total_marks,
    :enable_test_output
  ]

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, @attrs)
    |> cast_assoc(:assignment_tests, with: &AssignmentTest.changeset/2)
    |> validate_required(@required_attrs)
    |> validate_number(:max_attempts, greater_than_or_equal_to: 0)
    |> validate_number(:penalty_per_day, greater_than_or_equal_to: 0)
    |> validate_number(:total_marks, greater_than_or_equal_to: 0)
    |> validate_number(:attempt_marks, greater_than_or_equal_to: 0)
    |> maybe_validate_start_date(attrs)
    |> maybe_validate_due_date()
    |> maybe_validate_cutoff_date()
    |> maybe_validate_attempt_marks()
    |> maybe_validate_penalty_per_day()
    |> maybe_validate_max_attempts()
    |> maybe_validate_total_marks()
  end

  def new_changeset(assignment, attrs) do
    assignment
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
  end

  defp maybe_validate_start_date(changeset, attrs) do
    case get_change(changeset, :start_date) do
      nil ->
        changeset

      start_date ->
        now = DateTime.utc_now() |> DateTime.shift_zone!(attrs["timezone"]) |> DateTime.to_naive()

        if NaiveDateTime.compare(start_date, now) == :lt do
          add_error(changeset, :start_date, "must be in the future")
        else
          changeset
        end
    end
  end

  defp maybe_validate_due_date(changeset) do
    case get_field(changeset, :due_date) do
      nil ->
        changeset

      due_date ->
        start_date = get_field(changeset, :start_date)

        if start_date && NaiveDateTime.compare(due_date, start_date) == :lt do
          add_error(changeset, :due_date, "must come after start date")
        else
          changeset
        end
    end
  end

  defp maybe_validate_cutoff_date(changeset) do
    if get_field(changeset, :enable_cutoff_date) do
      changeset
      |> validate_required(:cutoff_date)
      |> validate_cutoff_date_order()
    else
      changeset
    end
  end

  defp validate_cutoff_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    due_date = get_field(changeset, :due_date)
    cutoff_date = get_field(changeset, :cutoff_date)

    if start_date && due_date && cutoff_date &&
         NaiveDateTime.compare(cutoff_date, due_date) == :lt do
      add_error(changeset, :cutoff_date, "must come after start date and due date")
    else
      changeset
    end
  end

  defp maybe_validate_attempt_marks(changeset) do
    if get_field(changeset, :enable_attempt_marks) do
      changeset
      |> validate_required(:attempt_marks)
      |> validate_attempt_marks_value()
    else
      changeset
    end
  end

  defp validate_attempt_marks_value(changeset) do
    attempt_marks = get_field(changeset, :attempt_marks)
    total_marks = get_field(changeset, :total_marks)

    if attempt_marks && total_marks && attempt_marks > total_marks do
      add_error(changeset, :attempt_marks, "cannot exceed total marks")
    else
      changeset
    end
  end

  defp maybe_validate_penalty_per_day(changeset) do
    if get_field(changeset, :enable_penalty_per_day) do
      validate_required(changeset, :penalty_per_day)
    else
      changeset
    end
  end

  defp maybe_validate_max_attempts(changeset) do
    if get_field(changeset, :enable_max_attempts) do
      validate_required(changeset, :max_attempts)
    else
      changeset
    end
  end

  defp maybe_validate_total_marks(changeset) do
    if get_field(changeset, :enable_total_marks) do
      validate_required(changeset, :total_marks)
    else
      changeset
    end
  end
end
