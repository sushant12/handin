defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Accounts.UsersRoles
  alias Handin.Modules.ModulesInvitations
  alias Handin.Accounts.User
  alias Handin.Repo

  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers

  @spec get_members(id :: integer) :: list(%User{})
  def get_members(id) do
    Module
    |> where([m], m.id == ^id)
    |> preload(users: :roles)
    |> Repo.one()
    |> Map.get(:users)
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

  @spec add_member(params :: %{user_id: integer, module_id: integer, role_id: integer}) ::
          {:ok, %User{}}
  def add_member(params) do
    Repo.transaction(fn ->
      UsersRoles.changeset(%UsersRoles{}, params) |> Repo.insert()
      ModulesUsers.changeset(%ModulesUsers{}, params) |> Repo.insert()
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

  def change_modules_invitations(%ModulesInvitations{} = modules_invitations, attrs \\ %{}) do
    ModulesInvitations.changeset(modules_invitations, attrs)
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
