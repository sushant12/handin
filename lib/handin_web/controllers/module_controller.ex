defmodule HandinWeb.ModuleController do
  use HandinWeb, :controller

  alias Handin.Accounts
  alias Handin.Courses
  alias Handin.Modules
  alias Handin.Modules.Module

  def index(conn, _) do
    render(conn, "index.html")
  end

  def new(conn, %{"mode" => mode} = _params) do
    render(conn, "new.html",
      mode: mode,
      courses: Courses.fetch_course_names_and_id(),
      modules: Modules.fetch_module_names(),
      teachers: Accounts.fetch_all_teaher_emails()
    )
  end

  def add_existing(conn, %{"courses" => courses_ids, "modules" => module_name} = _params) do
    module = Handin.Repo.get_by(Module, name: module_name)

    with courses <-
           Enum.map(courses_ids, fn id ->
             unless Courses.get_course!(id) do
               Modules.add_module_to_course(%{module_id: module.id, course_id: id})
             end
           end),
         false <- Enum.empty?(courses) do
      conn
      |> put_flash(:info, "Module added successfully")
      |> redirect(to: Routes.module_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Module was already added")
        |> render("new.html",
          mode: "create",
          courses: Courses.fetch_course_names_and_id(),
          modules: Modules.fetch_module_names(),
          teachers: Accounts.fetch_all_teaher_emails()
        )
    end
  end

  def create_module(conn, params) do
    with {:ok, module} <- Modules.create_module(params),
         {:ok, _} <-
           Accounts.add_module(
             Accounts.get_user_by_email(params["teacher"]),
             module.id
           ) do
      if courses_ids = params["courses"] do
        for id <- courses_ids do
          Modules.add_module_to_course(%{module_id: module.id, course_id: id})
        end
      end

      conn
      |> put_flash(:info, "Module created successfully")
      |> redirect(to: Routes.module_path(conn, :index))
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Module already exists")
        |> render("new.html",
          mode: "create",
          courses: Courses.fetch_course_names_and_id(),
          modules: Modules.fetch_module_names(),
          teachers: Accounts.fetch_all_teaher_emails()
        )
    end
  end
end
