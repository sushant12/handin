defmodule HandinWeb.Admin.ModuleController do
  use HandinWeb, :controller

  alias Handin.Modules
  alias Handin.Modules.Module

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Modules.paginate_modules(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Modules. #{inspect(error)}")
        |> redirect(to: ~p"/admin/modules")
    end
  end

  def new(conn, _params) do
    changeset = Modules.change_module(%Module{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"module" => module_params}) do
    case Modules.create_module(module_params, Map.get(module_params, "user_id")) do
      {:ok, module} ->
        conn
        |> put_flash(:info, "Module created successfully.")
        |> redirect(to: ~p"/admin/modules/#{module}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    module = Modules.get_module!(id)
    render(conn, :show, module: module)
  end

  def edit(conn, %{"id" => id}) do
    module = Modules.get_module!(id)
    changeset = Modules.change_module(module)
    render(conn, :edit, module: module, changeset: changeset)
  end

  def update(conn, %{"id" => id, "module" => module_params}) do
    module = Modules.get_module!(id)

    case Modules.update_module(module, module_params) do
      {:ok, module} ->
        conn
        |> put_flash(:info, "Module updated successfully.")
        |> redirect(to: ~p"/admin/modules/#{module}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, module: module, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    module = Modules.get_module!(id)
    {:ok, _module} = Modules.delete_module(module)

    conn
    |> put_flash(:info, "Module deleted successfully.")
    |> redirect(to: ~p"/admin/modules")
  end
end
