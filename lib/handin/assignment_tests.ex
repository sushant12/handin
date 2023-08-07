defmodule Handin.AssignmentTests do
  @moduledoc """
  The AssignmentTests context.
  """

  import Ecto.Query, warn: false

  alias Handin.{Repo, Assignments}

  alias Handin.AssignmentTests.AssignmentTest

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
    assignment = Assignments.get_assignment!(attrs["assignment_id"])

    %AssignmentTest{}
    |> AssignmentTest.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:assignment, assignment)
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
  end
end
