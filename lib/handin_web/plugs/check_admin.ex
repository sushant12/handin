defmodule HandinWeb.Plugs.CheckAdmin do
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _) do
    if admin?(conn) do
      conn
    else
      conn
      |> redirect(to: "/")
    end
  end

  defp admin?(%Plug.Conn{assigns: %{current_user: user}}) do
    user && user.admin
  end
end
