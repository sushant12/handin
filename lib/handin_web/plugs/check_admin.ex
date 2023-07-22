defmodule HandinWeb.Plugs.CheckAdmin do
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _) do
    if admin?(conn) do
      conn
    else
      if conn.request_path == "/admin/log_in" do
        conn
      else
        conn
        |> redirect(to: "/admin/log_in")
      end
    end
  end

  defp admin?(%Plug.Conn{assigns: %{current_user: user}}) do
    user && user.admin
  end
end
