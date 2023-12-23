defmodule Handin.Assignments.Assignment do
  use Handin.Schema

  import Ecto.Changeset
  alias Handin.Modules.Module
  alias Handin.ProgrammingLanguages.ProgrammingLanguage
  alias Handin.Assignments.{AssignmentTest, Build, SupportFile, SolutionFile, RunScriptResult}
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
    field :enable_cutoff_date, :boolean, default: false
    field :enable_attempt_marks, :boolean, default: false
    field :enable_penalty_per_day, :boolean, default: false
    field :enable_max_attemps, :boolean, default: false
    field :enable_total_marks, :boolean, default: false
    field :enable_test_output, :boolean, default: false

    belongs_to :module, Module
    belongs_to :programming_language, ProgrammingLanguage, on_replace: :nilify

    has_many :assignment_tests, AssignmentTest,
      on_delete: :delete_all,
      preload_order: [asc: :inserted_at]

    has_many :assignment_submissions, AssignmentSubmission, on_delete: :delete_all
    has_many :builds, Build, preload_order: [asc: :inserted_at]
    has_many :support_files, SupportFile, on_delete: :delete_all
    has_many :solution_files, SolutionFile, on_delete: :delete_all
    has_many :run_script_results, RunScriptResult, on_delete: :delete_all

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
    :enable_max_attemps,
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
    |> maybe_validate_cutoff_date()
    |> maybe_validate_attempt_marks()
    |> maybe_validate_penalty_per_day()
    |> maybe_validate_max_attempts()
    |> maybe_validate_total_marks()
    |> maybe_validate_test_output()
    |> maybe_validate_due_date()
    |> maybe_validate_cutoff_date()
  end

  defp maybe_validate_cutoff_date(changeset) do
    if get_field(changeset, :enable_cutoff_date) do
      validate_required(changeset, :cutoff_date)
    else
      changeset
    end
  end

  defp maybe_validate_attempt_marks(changeset) do
    if get_field(changeset, :enable_attempt_marks) do
      validate_required(changeset, :attempt_marks)
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
    if get_field(changeset, :enable_max_attemps) do
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

  defp maybe_validate_test_output(changeset) do
    if get_field(changeset, :enable_test_output) do
    #   validate_required(changeset, :run_script)
    # else
      changeset
    end
  end

  defp maybe_validate_due_date(changeset) do
    case get_field(changeset, :due_date) do
      nil ->
        changeset

      due_date ->
        validate_date(
          changeset,
          :due_date,
          get_field(changeset, :start_date),
          due_date,
          "must come after start date"
        )
    end
  end

  defp maybe_validate_cutoff_date(changeset) do
    case get_field(changeset, :cutoff_date) do
      nil ->
        changeset

      cutoff_date ->
        validate_date(
          changeset,
          :cutoff_date,
          get_field(changeset, :start_date),
          cutoff_date,
          "must come after start date"
        )
    end
  end

  defp validate_date(changeset, field, date, reference_date, error) do
    if Timex.compare(date, reference_date) > 0 do
      add_error(changeset, field, error)
    else
      changeset
    end
  end
end
