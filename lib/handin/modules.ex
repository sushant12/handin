defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Assignments.CustomAssignmentDate
  alias Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Modules.ModulesInvitations
  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers

  @spec get_students(module_id :: Ecto.UUID) :: list(User.t())
  def get_students(module_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == :student)
    |> select([m, u], u)
    |> Repo.all()
  end

  def get_students_without_custom_assignment_date(module_id, assignment_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == :student)
    |> join(:left, [m, u], cad in assoc(u, :custom_assignment_dates),
      on: cad.user_id == u.id and cad.assignment_id == ^assignment_id
    )
    |> where([m, u, cad], is_nil(cad.id))
    |> select([m, u], u)
    |> Repo.all()
  end

  @spec get_students_count(module_id :: Ecto.UUID) :: integer()
  def get_students_count(module_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == :student)
    |> select([m, u], count(u.id))
    |> Repo.one()
  end

  def get_assignments_count(module_id, user) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], a in assoc(m, :assignments), on: a.module_id == ^module_id)
    |> maybe_filter_by_released_assignment(user)
    |> select([m, a], count(a.id))
    |> Repo.one()
  end

  def list_module() do
    Repo.all(Module)
  end

  def get_module!(id),
    do: Repo.get!(Module, id) |> Repo.preload(assignments: [:programming_language])

  @spec create_module(attrs :: %{name: String.t(), code: String.t()}, user_id :: Ecto.UUID) ::
          {:ok, Module.t()} | {:error, %Ecto.Changeset{}}
  def create_module(attrs, user_id) do
    Repo.transaction(fn ->
      case Module.changeset(%Module{}, attrs) |> Repo.insert() do
        {:ok, module} ->
          ModulesUsers.changeset(%ModulesUsers{}, %{module_id: module.id, user_id: user_id})
          |> Repo.insert!()

          module

        {:error, changeset} ->
          Handin.Repo.rollback(changeset)
      end
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

      Repo.delete(module_invitation)
    end)
  end

  def list_modules_invitations_for_module(id) do
    ModulesInvitations
    |> where([mi], mi.module_id == ^id)
    |> Repo.all()
  end

  def get_pending_students(module_id) do
    list_modules_invitations_for_module(module_id)
    |> Enum.map(&%User{id: &1.id, email: &1.email})
  end

  def get_modules_invitations(mi_id) do
    ModulesInvitations
    |> where([mi], mi.id == ^mi_id)
    |> Repo.one()
  end

  def delete_modules_invitations(id) do
    ModulesInvitations
    |> where([mi], mi.id == ^id)
    |> Repo.one()
    |> Repo.delete()
  end

  def assignment_exists?(module_id, assignment_id) do
    get_module!(module_id)
    |> Map.get(:assignments)
    |> Enum.any?(&(&1.id == assignment_id))
  end

  def list_assignments_for(id, user) do
    Module
    |> where([m], m.id == ^id)
    |> join(:inner, [m], a in assoc(m, :assignments), on: a.module_id == ^id)
    |> order_by([m, a], asc: a.start_date)
    |> select([m, a], a)
    |> maybe_filter_by_released_assignment(user)
    |> Repo.all()
    |> Repo.preload([:programming_language])
  end

  defp maybe_filter_by_released_assignment(query, user) do
    case user.role do
      :student ->
        now = DateTime.utc_now() |> DateTime.shift_zone!(user.university.timezone)

        query
        |> where(
          [m, a],
          a.id in subquery(
            CustomAssignmentDate
            |> select([cad], cad.assignment_id)
            |> where([cad], cad.user_id == ^user.id and cad.start_date <= ^now)
          ) or a.start_date <= ^now
        )

      _ ->
        query
    end
  end
end
