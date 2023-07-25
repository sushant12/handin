defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Repo

  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers
  alias Handin.Accounts.User

  @spec list_modules_for_user(user_id :: integer) :: list(%Module{})
  def list_modules_for_user(user_id) do
    Module
    |> join(:inner, [m], mu in assoc(m, :users))
    |> order_by([m], asc: m.name)
    |> Repo.all()
  end

  @doc """
  Returns the list of module.

  ## Examples

      iex> list_module()
      [%Module{}, ...]

  """
  def list_module() do
    Repo.all(Module)
  end

  @doc """
  Gets a single module.

  Raises `Ecto.NoResultsError` if the Module does not exist.

  ## Examples

      iex> get_module!(123)
      %Module{}

      iex> get_module!(456)
      ** (Ecto.NoResultsError)

  """
  def get_module!(id), do: Repo.get(Module, id)

  @spec create_module(attrs :: map(), user_id :: integer) :: {:ok, %Module{}}
  def create_module(attrs \\ %{}, user_id) do
    Repo.transaction(fn ->
      module =
        %Module{}
        |> Module.changeset(attrs)
        |> Repo.insert!()

      ModulesUsers.changeset(%ModulesUsers{}, %{
        module_id: module.id,
        user_id: user_id
      })
      |> Repo.insert!()

      module
    end)
  end

  @doc """
  Updates a module.

  ## Examples

      iex> update_module(module, %{field: new_value})
      {:ok, %Module{}}

      iex> update_module(module, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_module(%Module{} = module, attrs) do
    module
    |> Module.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a module.

  ## Examples

      iex> delete_module(module)
      {:ok, %Module{}}

      iex> delete_module(module)
      {:error, %Ecto.Changeset{}}

  """
  def delete_module(%Module{} = module) do
    Repo.delete(module)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking module changes.

  ## Examples

      iex> change_module(module)
      %Ecto.Changeset{data: %Module{}}

  """
  def change_module(%Module{} = module, attrs \\ %{}) do
    Module.changeset(module, attrs)
  end

  def register_user_into_module(attrs) do
    %ModulesUsers{}
    |> ModulesUsers.changeset(attrs)
    |> Repo.insert()
  end

  def fetch_module_names() do
    Module
    |> select([m], m.name)
    |> Repo.all()
  end
end
