defmodule HandinWeb.Admin.BuildController do
  use HandinWeb, :controller

  alias Handin.{Builds, Assignments}
  alias Handin.Assignments.Build

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Builds.paginate_builds(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Builds. #{inspect(error)}")
        |> redirect(to: ~p"/admin/builds")
    end
  end

  def new(conn, _params) do
    changeset = Assignments.change_build(%Build{})
    render(conn, :new, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    build = Assignments.get_build!(id)
    render(conn, :show, build: build)
  end

  def edit(conn, %{"id" => id}) do
    build = Assignments.get_build!(id)
    changeset = Assignments.change_build(build)
    render(conn, :edit, build: build, changeset: changeset)
  end

  def update(conn, %{"id" => id, "build" => build_params}) do
    build = Assignments.get_build!(id)

    case Assignments.update_build(build, build_params) do
      {:ok, build} ->
        conn
        |> put_flash(:info, "Build updated successfully.")
        |> redirect(to: ~p"/admin/builds/#{build}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, build: build, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    build = Assignments.get_build!(id)
    {:ok, _build} = Assignments.delete_build(build)

    conn
    |> put_flash(:info, "Build deleted successfully.")
    |> redirect(to: ~p"/admin/builds")
  end
end
