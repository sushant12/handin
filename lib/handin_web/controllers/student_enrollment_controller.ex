defmodule HandinWeb.StudentEnrollmentController do
  use HandinWeb, :controller

  alias Handin.Modules

  def new(conn, %{"module_id" => id}) do
    with {:ok, module} <- Modules.get_module(id) do
      render(conn, "new.html", module_name: module.name, module_id: id)
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def create(conn, %{"module_id" => id}) do
    {:ok, module} = Modules.get_module(id)
    student = conn.assigns[:current_user]
    Modules.register_user_into_module(%{user_id: student.id, module_id: module.id})

    conn
    |> put_flash(:info, "Joined module successfully")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
