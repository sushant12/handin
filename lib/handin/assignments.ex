defmodule Handin.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Handin.Repo

  alias Handin.Assignments.{Assignment, AssignmentTest, SupportFile, SolutionFile}

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
        :solution_files
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
end
