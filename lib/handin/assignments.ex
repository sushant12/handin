defmodule Handin.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Handin.Repo

  alias Handin.Assignments.{
    Assignment,
    AssignmentTest,
    SupportFile,
    SolutionFile,
    Build,
    Log,
    RunScriptResult,
    TestResult
  }

  alias Handin.AssignmentSubmission.{AssignmentSubmission, AssignmentSubmissionFile}

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
  def get_assignment!(id),
    do:
      Repo.get!(Assignment, id)
      |> Repo.preload([
        :programming_language,
        :assignment_tests,
        :support_files,
        :solution_files,
        assignment_submissions: [:user],
        builds: [:logs]
      ])

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

  def create_support_file(attrs \\ %{}) do
    %SupportFile{}
    |> SupportFile.changeset(attrs)
    |> Repo.insert()
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

  def get_support_file!(id), do: Repo.get!(SupportFile, id)

  @spec get_support_file_by_name!(assignment_id :: Ecto.UUID, support_file_name :: String.t()) ::
          SupportFile.t()
  def get_support_file_by_name!(assignment_id, support_file_name) do
    get_assignment!(assignment_id)
    |> Map.get(:support_files)
    |> Enum.find(&(&1.file.file_name == support_file_name))
  end

  def get_solution_file!(id), do: Repo.get!(SolutionFile, id)

  def delete_support_file(%SupportFile{} = support_file) do
    Repo.delete(support_file)
  end

  def delete_solution_file(%SolutionFile{} = solution_file) do
    Repo.delete(solution_file)
  end

  def delete_assignment_submission_file(%AssignmentSubmissionFile{} = submission_file) do
    Repo.delete(submission_file)
  end

  def change_support_file(%SupportFile{} = support_file, attrs \\ %{}) do
    SupportFile.changeset(support_file, attrs)
  end

  def save_support_file(attrs \\ %{}) do
    %SupportFile{}
    |> SupportFile.changeset(attrs)
    |> Repo.insert()
  end

  def save_solution_file(attrs \\ %{}) do
    %SolutionFile{}
    |> SolutionFile.changeset(attrs)
    |> Repo.insert()
  end

  def save_assignment_submission_file!(attrs \\ %{}) do
    %AssignmentSubmissionFile{}
    |> AssignmentSubmissionFile.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(assignment_submission: [:user, :assignment])
  end

  def upload_support_file(support_file, attrs \\ %{}) do
    support_file
    |> SupportFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def upload_solution_file(solution_file, attrs \\ %{}) do
    solution_file
    |> SolutionFile.file_changeset(attrs)
    |> Repo.update!()
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
            status: String.t(),
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
          attrs :: %{status: String.t()} | %{machine_id: String.t()}
        ) :: {:ok, Build.t()}
  def update_build(build, attrs) do
    Build.update_changeset(build, attrs)
    |> Repo.update()
  end

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
      |> Enum.sort_by(& &1.inserted_at, :desc)
      |> List.first()

    if build do
      build |> Map.get(:logs) |> Enum.sort_by(& &1.inserted_at, :asc)
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
        %{
          type: "test_result",
          state: test_result.state,
          name: test_result.assignment_test.name,
          command: test_result.assignment_test.command,
          output:
            build.logs
            |> Enum.find(%{}, &(&1.assignment_test_id == test_result.assignment_test_id))
            |> Map.get(:output),
          expected_output:
            if test_result.assignment_test.expected_output_type == "text" do
              test_result.assignment_test.expected_output_text
            else
              test_result.assignment_test.expected_output_file_content
            end
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
      submission -> Repo.preload(submission, [:assignment_submission_files, :user])
    end
  end

  def get_submission(assignment_id, user_id) do
    AssignmentSubmission
    |> where([as], as.assignment_id == ^assignment_id)
    |> where([as], as.user_id == ^user_id)
    |> order_by([as], desc: as.inserted_at)
    |> preload([:assignment_submission_files])
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
  end

  def get_submissions_for_assignment(assignment_id) do
    AssignmentSubmission
    |> where([as], as.assignment_id == ^assignment_id)
    |> preload([as], :user)
    |> Repo.all()
    |> Enum.with_index(1)
  end

  def submit_assignment(assignment_submission_id) do
    now = DateTime.utc_now()

    AssignmentSubmission
    |> where([as], as.id == ^assignment_submission_id)
    |> update([as], inc: [retries: 1], set: [submitted_at: ^now])
    |> Repo.update_all([])
  end

  def create_submission(assignment_id, user_id) do
    %AssignmentSubmission{}
    |> AssignmentSubmission.changeset(%{
      assignment_id: assignment_id,
      user_id: user_id
    })
    |> Repo.insert()
  end
end
