defmodule HandinWeb.Admin.ModulesUsersController do
  use HandinWeb, :controller

  alias Handin.Modules
  alias Handin.Modules.ModulesUsers
  alias Handin.Accounts.User

  alias Handin.Modules.AddUserToModuleParams

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def new(conn, %{"module_id" => module_id}) do
    changeset = Modules.change_modules_users(%ModulesUsers{})
    render(conn, :new, changeset: changeset, module_id: module_id)
  end

  def create(conn, %{"modules_users" => modules_users_params}) do
    %{"module_id" => module_id, "email" => email} = modules_users_params

    {:ok, module} = Modules.get_module(module_id)

    params =
      %AddUserToModuleParams{
        users: [%User{email: email}],
        module: module
      }

    case Modules.add_users_to_module(params) do
      {:ok, _modules_users} ->
        conn
        |> put_flash(:info, "User added successfully.")
        |> redirect(to: ~p"/admin/modules/#{module_id}/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, module_id: module_id)
    end
  end

  def show(conn, %{"id" => id, "module_id" => module_id}) do
    modules_users = Modules.get_modules_users!(id)

    render(conn, :show, modules_users: modules_users, module_id: module_id)
  end

  def edit(conn, %{"id" => id, "module_id" => module_id}) do
    modules_users = Modules.get_modules_users!(id)
    changeset = Modules.change_modules_users(modules_users)
    render(conn, :edit, modules_users: modules_users, changeset: changeset, module_id: module_id)
  end

  def update(conn, %{"id" => id, "modules_users" => modules_users_params}) do
    modules_users = Modules.get_modules_users!(id)

    case Modules.update_modules_users(modules_users, modules_users_params) do
      {:ok, modules_users} ->
        conn
        |> put_flash(:info, "Modules users updated successfully.")
        |> redirect(
          to: ~p"/admin/modules/#{modules_users.module_id}/modules_users/#{modules_users}"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, modules_users: modules_users, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    modules_users = Modules.get_modules_users!(id)
    {:ok, _modules_users} = Modules.delete_modules_users(modules_users)

    conn
    |> put_flash(:info, "Modules users deleted successfully.")
    |> redirect(to: ~p"/admin/modules/#{modules_users.module_id}/")
  end
end
