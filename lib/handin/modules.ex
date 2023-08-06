defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Accounts
  alias Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesInvitations
  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers

  @spec get_students(id :: integer) :: list(User.t())
  def get_students(id) do
    Module
    |> where([m], m.id == ^id)
    |> preload([m], [:users])
    |> Repo.one()
    |> Map.get(:users)
    |> Enum.filter(&(&1.role == "student"))
  end

  def get_students_count(id) do
    Module
    |> where([m], m.id == ^id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == "student")
    |> select([m, u], count(u.id))
    |> Repo.one()
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

  def get_module!(id),
    do: Repo.get(Module, id) |> Repo.preload(assignments: [:programming_language])

  @spec create_module(attrs :: map(), user_id :: integer) :: {:ok, Module.t()}
  def create_module(attrs \\ %{}, user_id) do
    user = Accounts.get_user!(user_id)

    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:modules, [
      %Module{code: attrs["code"], name: attrs["name"]} | user.modules
    ])
    |> Repo.update()
    |> case do
      {:ok, user} ->
        module =
          user.modules
          |> Enum.find(&(&1.code == attrs["code"] and &1.name == attrs["name"]))

        {:ok, module}

      err ->
        err
    end
  end

  @spec add_member(params :: %{user_id: integer, module_id: integer}) ::
          {:ok, User.t()}
  def add_member(params) do
    ModulesUsers.changeset(%ModulesUsers{}, params) |> Repo.insert()
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

  @spec add_modules_invitations(params :: %{email: String, module_id: Integer}) ::
          {:ok, ModulesInvitations.t()}
  def add_modules_invitations(params) do
    change_modules_invitations(%ModulesInvitations{}, params) |> Repo.insert()
  end

  def register_user_into_module(attrs) do
    %ModulesUsers{}
    |> ModulesUsers.changeset(attrs)
    |> Repo.insert()
  end

  def remove_user_from_module(user_id, module_id) do
    ModulesUsers
    |> where([mu], mu.user_id == ^user_id and mu.module_id == ^module_id)
    |> Repo.one()
    |> Repo.delete()
  end

  def fetch_module_names() do
    Module
    |> select([m], m.name)
    |> Repo.all()
  end

  def check_and_add_new_user_modules_invitations(user) do
    ModulesInvitations
    |> where([mi], mi.email == ^user.email)
    |> Repo.all()
    |> Enum.each(fn module_invitation ->
      add_member(%{
        user_id: user.id,
        module_id: module_invitation.module_id
      })
    end)
  end
end
