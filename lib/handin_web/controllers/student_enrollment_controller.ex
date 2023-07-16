defmodule HandinWeb.StudentEnrollmentController do
  use HandinWeb, :controller

  alias Handin.Modules
  alias Handin.Modules.Module

  def new(conn, %{"module_id" => id}) do
    with %Module{} = module <- Modules.get_module!(id) do
      render(conn, :new, module_name: module.name, module_id: id)
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: ~p"/")
    end
  end

  def create(conn, %{"module_id" => id}) do
    module = Modules.get_module!(id)
    student = conn.assigns[:current_user]
    Modules.register_user_into_module(%{user_id: student.id, module_id: module.id})

    conn
    |> put_flash(:info, "Joined module successfully")
    |> redirect(to: ~p"/")
  end
end
