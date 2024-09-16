defmodule HandinWeb.Plugs.CheckArchivedModule do
  use HandinWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller
  alias Handin.Modules

  def init(opts), do: opts

  def call(conn, _opts) do
    module_id = conn.path_params["id"]

    case Modules.get_module(module_id) do
      {:ok, module} ->
        if module.archived do
          conn
          |> put_flash(
            :error,
            "This module is archived. Please unarchive it to view its contents."
          )
          |> redirect(to: ~p"/modules")
          |> halt()
        else
          conn
        end

      {:error, _} ->
        conn
        |> put_flash(:error, "Module not found")
        |> redirect(to: ~p"/modules")
        |> halt()
    end
  end
end
