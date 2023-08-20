defmodule Handin.AssignmentTests do
  @moduledoc """
  The AssignmentTests context.
  """

  import Ecto.Query, warn: false

  alias Handin.{Repo}

  alias Handin.Assignments.{AssignmentTest, TestSupportFile, Log}

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
  def get_assignment_test!(id), do: Repo.get!(AssignmentTest, id)

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
    |> Repo.preload(:test_support_files)
  end

  def create_test_support_file(attrs \\ %{}) do
    %TestSupportFile{}
    |> TestSupportFile.changeset(attrs)
    |> Repo.insert()
  end

  def get_test_support_file!(id), do: Repo.get!(TestSupportFile, id)

  def delete_test_support_file(%TestSupportFile{} = test_support_file) do
    Repo.delete(test_support_file)
  end

  def change_test_support_file(%TestSupportFile{} = test_support_file, attrs \\ %{}) do
    TestSupportFile.changeset(test_support_file, attrs)
  end

  def get_test_support_files_for_test(test_id) do
    TestSupportFile
    |> where([t], t.assignment_test_id == ^test_id)
    |> Repo.all()
  end

  def save_test_support_file(attrs \\ %{}) do
    %TestSupportFile{}
    |> TestSupportFile.changeset(attrs)
    |> Repo.insert()
  end

  def upload_test_support_file(test_support_file, attrs \\ %{}) do
    test_support_file
    |> TestSupportFile.file_changeset(attrs)
    |> Repo.update()
  end

  @spec log(assignment_test_id :: Ecto.UUID, description :: String.t()) :: Log.t()
  def log(assignment_test_id, description) do
    Log.changeset(%{assignment_test_id: assignment_test_id, description: description})
    |> Repo.insert()
  end

  @spec delete_logs(assignment_test_id :: Ecto.UUID) :: {non_neg_integer(), nil}
  def delete_logs(assignment_test_id) do
    Log |> where([l], l.assignment_test_id == ^assignment_test_id) |> Repo.delete_all()
  end
end
