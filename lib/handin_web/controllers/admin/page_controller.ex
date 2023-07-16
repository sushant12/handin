defmodule HandinWeb.Admin.PageController do
  use HandinWeb, :controller

  def index(conn, _params) do
    render(conn, :home)
  end
end
