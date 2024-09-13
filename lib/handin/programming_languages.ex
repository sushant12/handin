defmodule Handin.ProgrammingLanguages do
  @moduledoc """
  The ProgrammingLanguages context.
  """

  import Ecto.Query, warn: false

  use Torch.Pagination,
    repo: Handin.Repo,
    model: Handin.ProgrammingLanguages.ProgrammingLanguage,
    name: :programming_languages

  alias Handin.Repo

  alias Handin.ProgrammingLanguages.ProgrammingLanguage

  @doc """
  Returns the list of programming_languages.

  ## Examples

      iex> list_programming_languages()
      [%ProgrammingLanguage{}, ...]

  """
  def list_programming_languages do
    Repo.all(ProgrammingLanguage)
  end

  @doc """
  Gets a single programming_language.

  Raises `Ecto.NoResultsError` if the Programming language does not exist.

  ## Examples

      iex> get_programming_language!(123)
      %ProgrammingLanguage{}

      iex> get_programming_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_programming_language!(id), do: Repo.get!(ProgrammingLanguage, id)

  @doc """
  Creates a programming_language.

  ## Examples

      iex> create_programming_language(%{field: value})
      {:ok, %ProgrammingLanguage{}}

      iex> create_programming_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_programming_language(attrs \\ %{}) do
    %ProgrammingLanguage{}
    |> ProgrammingLanguage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a programming_language.

  ## Examples

      iex> update_programming_language(programming_language, %{field: new_value})
      {:ok, %ProgrammingLanguage{}}

      iex> update_programming_language(programming_language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_programming_language(%ProgrammingLanguage{} = programming_language, attrs) do
    programming_language
    |> ProgrammingLanguage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a programming_language.

  ## Examples

      iex> delete_programming_language(programming_language)
      {:ok, %ProgrammingLanguage{}}

      iex> delete_programming_language(programming_language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_programming_language(%ProgrammingLanguage{} = programming_language) do
    Repo.delete(programming_language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking programming_language changes.

  ## Examples

      iex> change_programming_language(programming_language)
      %Ecto.Changeset{data: %ProgrammingLanguage{}}

  """
  def change_programming_language(%ProgrammingLanguage{} = programming_language, attrs \\ %{}) do
    ProgrammingLanguage.changeset(programming_language, attrs)
  end
end
