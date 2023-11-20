defmodule Handin.AssignmentTests do
  @moduledoc """
  The AssignmentTests context.
  """

  import Ecto.Query, warn: false

  alias Handin.{Repo}

  alias Handin.Assignments.{AssignmentTest, TestSupportFile, Log, Build, Command, SolutionFile}

  @doc """
  Returns the list of assignment_tests.

  ## Examples

      iex> list_assignment_tests()
      [%AssignmentTest{}, ...]

  """
  def list_assignment_tests do
    Repo.all(AssignmentTest)
  end

  @doc """
  Gets a single assignment_test.

  Raises `Ecto.NoResultsError` if the Assignment test does not exist.

  ## Examples

      iex> get_assignment_test!(123)
      %AssignmentTest{}

      iex> get_assignment_test!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assignment_test!(id),
    do:
      Repo.get!(AssignmentTest, id)
      |> Repo.preload([:commands, :test_support_files, :solution_files, builds: :logs])

  @doc """
  Creates a assignment_test.

  ## Examples

      iex> create_assignment_test(%{field: value})
      {:ok, %AssignmentTest{}}

      iex> create_assignment_test(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment_test(attrs \\ %{}) do
    %AssignmentTest{}
    |> AssignmentTest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a assignment_test.

  ## Examples

      iex> update_assignment_test(assignment_test, %{field: new_value})
      {:ok, %AssignmentTest{}}

      iex> update_assignment_test(assignment_test, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assignment_test(%AssignmentTest{} = assignment_test, attrs) do
    assignment_test
    |> AssignmentTest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a assignment_test.

  ## Examples

      iex> delete_assignment_test(assignment_test)
      {:ok, %AssignmentTest{}}

      iex> delete_assignment_test(assignment_test)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assignment_test(%AssignmentTest{} = assignment_test) do
    Repo.delete(assignment_test)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assignment_test changes.

  ## Examples

      iex> change_assignment_test(assignment_test)
      %Ecto.Changeset{data: %AssignmentTest{}}

  """
  def change_assignment_test(%AssignmentTest{} = assignment_test, attrs \\ %{}) do
    AssignmentTest.changeset(assignment_test, attrs)
  end

  def list_assignment_tests_for_assignment(id) do
    AssignmentTest
    |> where([at], at.assignment_id == ^id)
    |> Repo.all()
    |> Repo.preload([:test_support_files, :solution_files])
  end

  def create_test_support_file(attrs \\ %{}) do
    %TestSupportFile{}
    |> TestSupportFile.changeset(attrs)
    |> Repo.insert()
  end

  def get_test_support_file!(id), do: Repo.get!(TestSupportFile, id)

  def get_solution_file!(id), do: Repo.get!(SolutionFile, id)

  def delete_test_support_file(%TestSupportFile{} = test_support_file) do
    Repo.delete(test_support_file)
  end

  def delete_solution_file(%SolutionFile{} = solution_file) do
    Repo.delete(solution_file)
  end

  def change_test_support_file(%TestSupportFile{} = test_support_file, attrs \\ %{}) do
    TestSupportFile.changeset(test_support_file, attrs)
  end

  def save_test_support_file(attrs \\ %{}) do
    %TestSupportFile{}
    |> TestSupportFile.changeset(attrs)
    |> Repo.insert()
  end

  def save_solution_file(attrs \\ %{}) do
    %SolutionFile{}
    |> SolutionFile.changeset(attrs)
    |> Repo.insert()
  end

  def upload_test_support_file(test_support_file, attrs \\ %{}) do
    test_support_file
    |> TestSupportFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def upload_solution_file(solution_file, attrs \\ %{}) do
    solution_file
    |> SolutionFile.file_changeset(attrs)
    |> Repo.update!()
  end

  def change_command(command) do
    Command.changeset(command, %{})
  end

  @spec log(build_id :: Ecto.UUID, description :: String.t()) :: Log.t()
  def log(build_id, description) do
    Log.changeset(%{build_id: build_id, description: description})
    |> Repo.insert()
  end

  @spec new_build(attrs :: %{assignment_test_id: Ecto.UUID, status: String.t()}) ::
          {:ok, Build.t()}
  def new_build(attrs) do
    Build.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_build(
          build :: Build.t(),
          attrs :: %{status: String.t()} | %{status: String.t(), machine_id: String.t()}
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

  def get_recent_build_logs(assignment_test_id) do
    assignment_test = get_assignment_test!(assignment_test_id)

    build =
      assignment_test.builds
      |> Enum.sort_by(& &1.inserted_at, :desc)
      |> List.first()

    if build do
      build |> Map.get(:logs) |> Enum.sort_by(& &1.inserted_at, :asc)
    else
      []
    end
  end

  def mark_solution_file(test_support_file) do
    Ecto.Changeset.change(test_support_file, solution_file: !test_support_file.solution_file && true)
    |> Repo.update()
  end
end
