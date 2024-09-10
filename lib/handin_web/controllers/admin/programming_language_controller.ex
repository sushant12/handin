defmodule HandinWeb.Admin.ProgrammingLanguageController do
  use HandinWeb, :controller

  alias Handin.ProgrammingLanguages
  alias Handin.ProgrammingLanguages.ProgrammingLanguage

  plug(:put_root_layout, {HandinWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case ProgrammingLanguages.paginate_programming_languages(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)
      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Programming languages. #{inspect(error)}")
        |> redirect(to: ~p"/admin/programming_languages")
    end
  end

  def new(conn, _params) do
    changeset = ProgrammingLanguages.change_programming_language(%ProgrammingLanguage{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"programming_language" => programming_language_params}) do
    case ProgrammingLanguages.create_programming_language(programming_language_params) do
      {:ok, programming_language} ->
        conn
        |> put_flash(:info, "Programming language created successfully.")
        |> redirect(to: ~p"/admin/programming_languages/#{programming_language}")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    programming_language = ProgrammingLanguages.get_programming_language!(id)
    render(conn, :show, programming_language: programming_language)
  end

  def edit(conn, %{"id" => id}) do
    programming_language = ProgrammingLanguages.get_programming_language!(id)
    changeset = ProgrammingLanguages.change_programming_language(programming_language)
    render(conn, :edit, programming_language: programming_language, changeset: changeset)
  end

  def update(conn, %{"id" => id, "programming_language" => programming_language_params}) do
    programming_language = ProgrammingLanguages.get_programming_language!(id)

    case ProgrammingLanguages.update_programming_language(programming_language, programming_language_params) do
      {:ok, programming_language} ->
        conn
        |> put_flash(:info, "Programming language updated successfully.")
        |> redirect(to: ~p"/admin/programming_languages/#{programming_language}")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, programming_language: programming_language, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    programming_language = ProgrammingLanguages.get_programming_language!(id)
    {:ok, _programming_language} = ProgrammingLanguages.delete_programming_language(programming_language)

    conn
    |> put_flash(:info, "Programming language deleted successfully.")
    |> redirect(to: ~p"/admin/programming_languages")
  end
end
