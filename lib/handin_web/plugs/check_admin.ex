defmodule HandinWeb.Plugs.CheckAdmin do
  import Phoenix.Controller
  alias HandinWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _) do
    if admin?(conn) do
      conn
    else
      if conn.request_path == Routes.admin_user_session_path(conn, :new) do
        conn
      else
        conn
        |> redirect(to: Routes.admin_user_session_path(conn, :new))
      end
    end
  end

  defp admin?(%Plug.Conn{assigns: %{current_user: user}}) do
    if user && user.role == "admin" do
      true
    else
      false
    end
  end
end
