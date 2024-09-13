defmodule HandinWeb.Admin.UniversityController do
  use HandinWeb, :controller

  alias Handin.Universities
  alias Handin.Universities.University

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Universities.paginate_universities(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Universities. #{inspect(error)}")
        |> redirect(to: ~p"/admin/universities")
    end
  end

  def new(conn, _params) do
    changeset = Universities.change_university(%University{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"university" => university_params}) do
    case Universities.create_university(university_params) do
      {:ok, university} ->
        conn
        |> put_flash(:info, "University created successfully.")
        |> redirect(to: ~p"/admin/universities/#{university}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    university = Universities.get_university!(id)
    render(conn, :show, university: university)
  end

  def edit(conn, %{"id" => id}) do
    university = Universities.get_university!(id)
    changeset = Universities.change_university(university)
    render(conn, :edit, university: university, changeset: changeset)
  end

  def update(conn, %{"id" => id, "university" => university_params}) do
    university = Universities.get_university!(id)

    case Universities.update_university(university, university_params) do
      {:ok, university} ->
        conn
        |> put_flash(:info, "University updated successfully.")
        |> redirect(to: ~p"/admin/universities/#{university}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, university: university, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    university = Universities.get_university!(id)
    {:ok, _university} = Universities.delete_university(university)

    conn
    |> put_flash(:info, "University deleted successfully.")
    |> redirect(to: ~p"/admin/universities")
  end
end
