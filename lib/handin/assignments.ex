defmodule Handin.Assignments do
  @moduledoc """
  The Assignments context.
  """
  alias Handin.Assignments
  use Timex
  import Ecto.Query, warn: false
  alias Handin.Repo

  alias Handin.Assignments.{
    Assignment,
    AssignmentFile,
    AssignmentTest,
    Build,
    Log,
    RunScriptResult,
    TestResult,
    CustomAssignmentDate
  }

  alias Handin.AssignmentSubmission.{AssignmentSubmission, AssignmentSubmissionFile}

  # def s3_links(assignment_id) do
  #   assignment_submissions =
  #     Assignments.get_submissions_for_assignment(assignment_id)
  #     |> Repo.preload([:assignment_submission_files, :user])

  #   assignment_submissions
  #   |> Enum.map(fn assignment_submission ->
  #     urls =
  #       assignment_submission.assignment_submission_files
  #       |> Enum.map(fn assignment_submission_file ->
  #         submission_file =
  #           Handin.AssignmentSubmissions.get_assignment_submission_file!(
  #             assignment_submission_file.id
  #           )

  #         url =
  #           Handin.AssignmentSubmissionFileUploader.url(
  #             {submission_file.file.file_name, submission_file},
  #             signed: true
  #           )

  #         %{url: url, name: submission_file.file.file_name}
  #       end)

  #     %{email: assignment_submission.user.email, urls: urls}
  #   end)
  # end

  @doc """
  Returns the list of assignments.

  ## Examples

      iex> list_assignments()
      [%Assignment{}, ...]

  """
  def list_assignments do
    Repo.all(Assignment)
  end

  @doc """
  Gets a single assignment.

  Raises `Ecto.NoResultsError` if the Assignment does not exist.

  ## Examples

      iex> get_assignment!(123)
      %Assignment{}

      iex> get_assignment!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_assignment(id :: Ecto.UUID, module_id :: Ecto.UUID) ::
          {:ok, Assignment.t()} | {:error, String.t()}
  def get_assignment(id, module_id) do
    from(a in Assignment, where: a.id == ^id and a.module_id == ^module_id)
    |> Repo.one()
    |> Repo.preload([:assignment_files, :programming_language])
    |> case do
      nil -> {:error, "Assignment not found"}
      assignment -> {:ok, assignment}
    end
  end

  def get_assignment!(id),
    do:
      Repo.get!(Assignment, id)
      |> Repo.preload([
        :programming_language,
        :assignment_tests,
        :assignment_files,
        assignment_submissions: [:user],
        builds: [:logs]
      ])

  @spec get_assignment_file(id :: Ecto.UUID.t()) ::
          {:ok, AssignmentFile.t()} | {:error, String.t()}
  def get_assignment_file(id) do
    from(af in AssignmentFile, where: af.id == ^id)
    |> Repo.one()
    |> case do
      nil -> {:error, "Assignment file not found"}
      assignment_file -> {:ok, assignment_file}
    end
  end

  @spec delete_assignment_file(assignment_file :: AssignmentFile.t()) ::
          {:ok, AssignmentFile.t()} | {:error, String.t()}
  def delete_assignment_file(%AssignmentFile{} = assignment_file) do
    Repo.delete(assignment_file)
  end

  @doc """
  Creates a assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment(attrs \\ %{}) do
    case %Assignment{}
         |> Assignment.changeset(attrs)
         |> Repo.insert() do
      {:ok, assignment} -> {:ok, assignment |> Repo.preload(:programming_language)}
      error -> error
    end
  end

  @doc """
  Updates a assignment.

  ## Examples

      iex> update_assignment(assignment, %{field: new_value})
      {:ok, %Assignment{}}

      iex> update_assignment(assignment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assignment(%Assignment{} = assignment, attrs) do
    assignment
    |> Repo.preload(:programming_language)
    |> Assignment.changeset(attrs)
    |> Repo.update()
  end

  def update_assignment_test(%AssignmentTest{} = assignment_test, attrs) do
    assignment_test
    |> AssignmentTest.changeset(attrs)
    |> Repo.update()
  end

  def update_new_assignment(%Assignment{} = assignment, attrs) do
    assignment
    |> Assignment.new_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a assignment.

  ## Examples

      iex> delete_assignment(assignment)
      {:ok, %Assignment{}}

      iex> delete_assignment(assignment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assignment(%Assignment{} = assignment) do
    Repo.delete(assignment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assignment changes.

  ## Examples

      iex> change_assignment(assignment)
      %Ecto.Changeset{data: %Assignment{}}

  """
  def change_assignment(%Assignment{} = assignment, attrs \\ %{}) do
    Assignment.changeset(assignment, attrs)
  end

  def change_new_assignment(%Assignment{} = assignment, attrs \\ %{}) do
    Assignment.new_changeset(assignment, attrs)
  end

  def change_assignment_test(%AssignmentTest{} = assignment_test, attrs \\ %{}) do
    AssignmentTest.changeset(assignment_test, attrs)
  end

  def create_assignment_test(attrs \\ %{}) do
    %AssignmentTest{}
    |> AssignmentTest.changeset(attrs)
    |> Repo.insert()
  end

  def valid_submission_date?(assignment) do
    now = DateTime.utc_now()

    DateTime.compare(assignment.start_date, now) == :lt &&
      DateTime.compare(assignment.cutoff_date, now) == :gt
  end

  def create_or_update_submission(
        %{user_id: user_id, assignment_id: assignment_id} = attrs \\ %{}
      ) do
    if submission = get_submission(assignment_id, user_id) do
      submission
    else
      %AssignmentSubmission{}
    end
    |> AssignmentSubmission.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def delete_assignment_submission_file(%AssignmentSubmissionFile{} = submission_file) do
    Repo.delete(submission_file)
  end

  def save_assignment_file(attrs) do
    %AssignmentFile{}
    |> AssignmentFile.changeset(attrs)
    |> Repo.insert()
  end

  def upload_assignment_file(assignment_file, attrs \\ %{}) do
    assignment_file
    |> AssignmentFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def save_assignment_submission_file!(attrs \\ %{}) do
    %AssignmentSubmissionFile{}
    |> AssignmentSubmissionFile.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end

  def upload_assignment_submission_file(submission_file, attrs \\ %{}) do
    submission_file
    |> AssignmentSubmissionFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def log(log_map) do
    Log.changeset(log_map)
    |> Repo.insert()
  end

  @spec new_build(
          attrs :: %{
            assignment_id: Ecto.UUID,
            status: :running | :failed | :completed,
            user_id: Ecto.UUID
          }
        ) ::
          {:ok, Build.t()}
  def new_build(attrs) do
    Build.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_build(
          build :: Build.t(),
          attrs :: %{status: :running | :failed | :completed} | %{machine_id: String.t()}
        ) :: {:ok, Build.t()}
  def update_build(build, attrs) do
    Build.update_changeset(build, attrs)
    |> Repo.update()
  end

  def list_builds(params) do
    case Flop.validate_and_run(Build, params, for: Build) do
      {:ok, {builds, meta}} ->
        %{builds: builds, meta: meta}

      {:error, meta} ->
        %{builds: [], meta: meta}
    end
  end

  def get_build!(id), do: Repo.get!(Build, id) |> Repo.preload([:assignment, :user])

  def delete_build(build), do: Repo.delete!(build)

  def get_logs(build_id) do
    Build
    |> Repo.get!(build_id)
    |> Repo.preload(:logs)
    |> Map.get(:logs)
  end

  def get_recent_build_logs(assignment_id) do
    assignment = get_assignment!(assignment_id)

    build =
      assignment.builds
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
      |> List.first()

    if build do
      build |> Map.get(:logs) |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    else
      []
    end
  end

  def save_run_script_results(attrs) do
    RunScriptResult.changeset(attrs)
    |> Repo.insert()
  end

  def save_test_results(attrs) do
    TestResult.changeset(attrs)
    |> Repo.insert()
  end

  def build_recent_test_results(assignment_id, user_id) do
    build =
      Build
      |> where([b], b.assignment_id == ^assignment_id)
      |> where([b], b.user_id == ^user_id)
      |> order_by([b], desc: b.inserted_at)
      |> limit(1)
      |> Repo.one()

    case build do
      nil ->
        []

      build ->
        get_test_results_for_build(build.id)
    end
  end

  def get_test_results_for_build(build_id) do
    build =
      Build
      |> Repo.get!(build_id)
      |> Repo.preload([
        :run_script_result,
        logs: [:assignment_test],
        test_results: [:assignment_test]
      ])

    test_results =
      build.test_results
      |> Enum.map(fn test_result ->
        log =
          Enum.find(build.logs, %{}, &(&1.assignment_test_id == test_result.assignment_test_id))

        %{
          type: "test_result",
          state: test_result.state,
          name: test_result.assignment_test.name,
          command: test_result.assignment_test.command,
          output: Map.get(log, :output),
          expected_output: Map.get(log, :expected_output)
        }
      end)

    run_script_results =
      if build.run_script_result do
        [
          %{
            type: "run_script_result",
            state: build.run_script_result.state,
            name: "Compiling files",
            command: "sh ./main.sh",
            output:
              build.logs
              |> Enum.find(&is_nil(&1.assignment_test_id))
              |> Map.get(:output),
            expected_output: ""
          }
        ]
      else
        []
      end

    Enum.with_index(run_script_results ++ test_results, &{&2, &1})
  end

  def get_running_build(assignment_id, user_id) do
    Build
    |> where([b], b.assignment_id == ^assignment_id)
    |> where([b], b.status == :running)
    |> where([b], b.user_id == ^user_id)
    |> order_by([b], desc: b.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def get_submission_by_id(submission_id) do
    AssignmentSubmission
    |> where([as], as.id == ^submission_id)
    |> Repo.one()
    |> case do
      nil -> nil
      submission -> Repo.preload(submission, [:assignment_submission_files, :user, :assignment])
    end
  end

  def get_submission(assignment_id, user_id) do
    AssignmentSubmission
    |> where([as], as.assignment_id == ^assignment_id)
    |> where([as], as.user_id == ^user_id)
    |> order_by([as], desc: as.inserted_at)
    |> preload([:assignment_submission_files, :assignment, user: [:university]])
    |> limit(1)
    |> Repo.one()
  end

  def get_submission_files(assignment_id, user_id) do
    AssignmentSubmission
    |> where([as], as.assignment_id == ^assignment_id)
    |> where([as], as.user_id == ^user_id)
    |> order_by([as], desc: as.inserted_at)
    |> limit(1)
    |> join(:inner, [as], asf in assoc(as, :assignment_submission_files))
    |> select([as, asf], asf)
    |> Repo.all()
    |> Enum.map(&Repo.preload(&1, assignment_submission: [:user, :assignment]))
  end

  def get_submissions_for_assignment(assignment_id) do
    AssignmentSubmission
    |> where([as], as.assignment_id == ^assignment_id)
    |> where([as], not is_nil(as.submitted_at))
    |> order_by([as], asc: as.submitted_at)
    |> preload([as], [:user, :assignment_submission_files, :assignment])
    |> Repo.all()
  end

  def get_submissions_for_user(module_id, user_id) do
    Assignment
    |> where([a], a.module_id == ^module_id)
    |> join(:inner, [a], as in assoc(a, :assignment_submissions))
    |> where([a, as], as.user_id == ^user_id)
    |> where([a, as], not is_nil(as.submitted_at))
    |> select([a, as], as)
    |> Repo.all()
    |> Enum.map(&Repo.preload(&1, [:assignment]))
  end

  def submit_assignment(assignment_submission_id, max_attempts_enabled) do
    now = DateTime.utc_now()

    AssignmentSubmission
    |> where([as], as.id == ^assignment_submission_id)
    |> maybe_update_retries_count(max_attempts_enabled)
    |> update([as], set: [submitted_at: ^now])
    |> Repo.update_all([])
  end

  defp maybe_update_retries_count(query, false), do: query
  defp maybe_update_retries_count(query, true), do: query |> update([as], inc: [retries: 1])

  def create_submission(assignment_id, user_id) do
    %AssignmentSubmission{}
    |> AssignmentSubmission.changeset(%{
      assignment_id: assignment_id,
      user_id: user_id
    })
    |> Repo.insert!()
    |> Repo.preload([:assignment_submission_files, :assignment, user: [:university]])
  end

  def evaluate_marks(submission_id, build_id) do
    submission =
      Repo.get(AssignmentSubmission, submission_id)
      |> Repo.preload([:assignment, user: [:university]])

    build =
      Repo.get(Build, build_id)
      |> Repo.preload([:run_script_result, test_results: [:assignment_test]])

    total_passed_tests_points = grade_test(build)

    total_points_after_attempt_marks =
      calculate_attempt_marks(submission.assignment, build, total_passed_tests_points)

    total_points_after_penalty =
      calculate_penalty_marks(submission.assignment, submission, total_points_after_attempt_marks)

    total_points = if total_points_after_penalty < 0, do: 0, else: total_points_after_penalty

    submission
    |> Handin.AssignmentSubmission.AssignmentSubmission.changeset(%{
      total_points: total_points
    })
    |> Repo.update()
  end

  defp grade_test(build) do
    build.test_results
    |> Enum.filter(&(&1.state == :pass))
    |> Enum.reduce(0, fn test_result, acc ->
      acc + test_result.assignment_test.points_on_pass
    end)
  end

  defp calculate_attempt_marks(assignment, build, marks) do
    if assignment.enable_attempt_marks && build.run_script_result.state == :pass do
      marks + assignment.attempt_marks
    else
      marks
    end
  end

  defp calculate_penalty_marks(assignment, submission, marks) do
    custom_date =
      Assignments.get_custom_assignment_date_by_user_and_assignment(
        submission.user_id,
        assignment.id
      )

    if custom_date do
      if assignment.enable_penalty_per_day &&
           Timex.after?(
             DateTime.shift_zone!(submission.submitted_at, submission.user.university.timezone),
             custom_date.due_date
           ) do
        days_after_due_date =
          Interval.new(
            from: custom_date.due_date,
            until:
              DateTime.shift_zone!(submission.submitted_at, submission.user.university.timezone)
          )
          |> Interval.duration(:days)

        penalty_percentage = (days_after_due_date + 1) * assignment.penalty_per_day / 100
        (marks * (1 - penalty_percentage)) |> Float.round(2)
      else
        marks
      end
    else
      if assignment.enable_penalty_per_day &&
           Timex.after?(
             DateTime.shift_zone!(submission.submitted_at, submission.user.university.timezone),
             assignment.due_date
           ) do
        days_after_due_date =
          Interval.new(
            from: assignment.due_date,
            until:
              DateTime.shift_zone!(submission.submitted_at, submission.user.university.timezone)
          )
          |> Interval.duration(:days)

        penalty_percentage = (days_after_due_date + 1) * assignment.penalty_per_day / 100
        (marks * (1 - penalty_percentage)) |> Float.round(2)
      else
        marks
      end
    end
  end

  def submission_allowed?(assignment_submission) do
    attempts_valid?(assignment_submission) &&
      submission_date_valid?(assignment_submission)
  end

  def get_submission_errors(assignment_submission) do
    errors = []

    errors =
      if attempts_valid?(assignment_submission),
        do: errors,
        else: ["Number of attempts exceeded" | errors]

    errors =
      if submission_date_valid?(assignment_submission),
        do: errors,
        else: ["Cutoff date exceeded" | errors]

    errors
  end

  defp submission_date_valid?(assignment_submission) do
    custom_date =
      Assignments.get_custom_assignment_date_by_user_and_assignment(
        assignment_submission.user_id,
        assignment_submission.assignment_id
      )

    if custom_date do
      if custom_date.enable_cutoff_date &&
           custom_date.cutoff_date do
        Timex.compare(
          DateTime.shift_zone!(
            DateTime.utc_now(),
            assignment_submission.user.university.timezone
          ),
          custom_date.cutoff_date
        ) < 0
      else
        true
      end
    else
      if assignment_submission.assignment.enable_cutoff_date &&
           assignment_submission.assignment.cutoff_date do
        Timex.compare(
          DateTime.shift_zone!(
            DateTime.utc_now(),
            assignment_submission.user.university.timezone
          ),
          assignment_submission.assignment.cutoff_date
        ) < 0
      else
        true
      end
    end
  end

  defp attempts_valid?(assignment_submission) do
    if assignment_submission.assignment.enable_max_attempts do
      assignment_submission.retries < assignment_submission.assignment.max_attempts
    else
      true
    end
  end

  def change_custom_assignment_date(
        %CustomAssignmentDate{} = custom_assignment_date,
        attrs \\ %{}
      ) do
    CustomAssignmentDate.changeset(custom_assignment_date, attrs)
  end

  def create_custom_assignment_date(attrs \\ %{}) do
    %CustomAssignmentDate{}
    |> CustomAssignmentDate.changeset(attrs)
    |> Repo.insert()
  end

  def update_custom_assignment_date(%CustomAssignmentDate{} = custom_assignment_date, attrs) do
    custom_assignment_date
    |> CustomAssignmentDate.changeset(attrs)
    |> Repo.update()
  end

  def list_custom_assignment_dates(assignment_id) do
    CustomAssignmentDate
    |> where(assignment_id: ^assignment_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get_custom_assignment_date(id),
    do: Repo.get(CustomAssignmentDate, id) |> Repo.preload(:user)

  def get_custom_assignment_date_by_user_and_assignment(user_id, assignment_id) do
    CustomAssignmentDate
    |> where([cad], cad.assignment_id == ^assignment_id and cad.user_id == ^user_id)
    |> Repo.one()
  end

  def delete_custom_assignment_date!(%CustomAssignmentDate{} = custom_assignment_date),
    do: Repo.delete!(custom_assignment_date)

  @spec list_tests(id :: Ecto.UUID.t()) :: [AssignmentTest.t()]
  def list_tests(id) do
    from(at in AssignmentTest, where: at.assignment_id == ^id, order_by: [asc: at.inserted_at])
    |> Repo.all()
  end

  @spec get_test(assignment_id :: Ecto.UUID.t(), test_id :: Ecto.UUID.t()) ::
          {:ok, AssignmentTest.t()} | {:error, String.t()}
  def get_test(assignment_id, test_id) do
    from(at in AssignmentTest, where: at.assignment_id == ^assignment_id and at.id == ^test_id)
    |> Repo.one()
    |> case do
      nil -> {:error, "Test not found"}
      test -> {:ok, test}
    end
  end

  def change_build(%Build{} = build, attrs \\ %{}) do
    build
    |> Build.update_changeset(attrs)
  end
end
