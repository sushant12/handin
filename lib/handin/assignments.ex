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
        :assignment_submissions,
        :programming_language,
        :assignment_tests,
        :support_files,
        :solution_files,
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

  def support_file_change(attrs \\ %{}) do
    %SupportFile{}
    |> SupportFile.changeset(attrs)
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

  def log(log_map) do
    Log.changeset(log_map)
    |> Repo.insert()
  end

  @spec new_build(
          attrs :: %{assignment_test_id: Ecto.UUID, assignment_id: Ecto.UUID, status: String.t()}
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

  def build_recent_test_results(assignment_id) do
    build =
      Build
      |> where([b], b.assignment_id == ^assignment_id)
      |> order_by([b], desc: b.inserted_at)
      |> limit(1)
      |> Repo.one()

    case build do
      nil ->
        []

      build ->
        build =
          build
          |> Repo.preload([
            :run_script_result,
            logs: [:assignment_test],
            test_results: [:assignment_test]
          ])

        test_results =
          build.test_results
          |> Enum.sort_by(& &1.inserted_at, :asc)
          |> Enum.map(fn test_result ->
            %{
              type: "test_result",
              state: test_result.state,
              name: test_result.assignment_test.name,
              command: test_result.assignment_test.command,
              output:
                build.logs
                |> Enum.find(&(&1.assignment_test_id == test_result.assignment_test_id))
                |> Map.get(:output),
              expected_output:
                if test_result.assignment_test.expected_output_type == "text" do
                  test_result.assignment_test.expected_output_text
                else
                  test_result.assignment_test.expected_output_file_content
                end
            }
          end)

        run_script_results = [
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

        run_script_results ++ test_results
    end
  end
end
