defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesInvitations
  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers

  @spec get_students(module_id :: Ecto.UUID) :: list(User.t())
  def get_students(module_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == "student")
    |> select([m, u], u)
    |> Repo.all()
  end

  @spec get_students(module_id :: Ecto.UUID) :: integer()
  def get_students_count(module_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == "student")
    |> select([m, u], count(u.id))
    |> Repo.one()
  end

  def list_module() do
    Repo.all(Module)
  end

  def get_module!(id),
    do: Repo.get(Module, id) |> Repo.preload(assignments: [:programming_language])

  @spec create_module(attrs :: %{name: String.t(), code: String.t()}, user_id :: Ecto.UUID) ::
          {:ok, Module.t()} | {:error, %Ecto.Changeset{}}
  def create_module(attrs, user_id) do
    Repo.transaction(fn ->
      module = Module.changeset(%Module{}, attrs) |> Repo.insert!()

      ModulesUsers.changeset(%ModulesUsers{}, %{module_id: module.id, user_id: user_id})
      |> Repo.insert!()
    end)
  end

  @spec add_member(params :: %{user_id: Ecto.UUID, module_id: Ecto.UUID}) ::
          {:ok, ModulesUsers.t()}
  def add_member(params) do
    ModulesUsers.changeset(%ModulesUsers{}, params) |> Repo.insert()
  end

  def update_module(%Module{} = module, attrs) do
    module
    |> Module.changeset(attrs)
    |> Repo.update()
  end

  def delete_module(%Module{} = module) do
    Repo.delete(module)
  end

  def change_module(%Module{} = module, attrs \\ %{}) do
    Module.changeset(module, attrs)
  end

  def change_modules_invitations(%ModulesInvitations{} = modules_invitations, attrs \\ %{}) do
    ModulesInvitations.changeset(modules_invitations, attrs)
  end

  @spec add_modules_invitations(params :: %{email: String.t(), module_id: Ecto.UUID}) ::
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
