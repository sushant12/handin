defmodule Handin.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Handin.ProgrammingLanguages
  alias Handin.{Repo, Modules}

  alias Handin.Assignments.Assignment

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
  def get_assignment!(id), do: Repo.get!(Assignment, id) |> Repo.preload(:programming_language)

  @doc """
  Creates a assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment(attrs \\ %{}) do
    module = Modules.get_module!(attrs["module_id"])

    case %Assignment{}
         |> Assignment.changeset(attrs)
         |> Ecto.Changeset.put_assoc(:module, module)
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
    language = ProgrammingLanguages.get_programming_language!(attrs["programming_language_id"])

    assignment
    |> Repo.preload(:programming_language)
    |> Assignment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:programming_language, language)
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
end
