defmodule HandinWeb.ModuleController do
  use HandinWeb, :controller

  alias Handin.{Accounts, Modules, Repo}
  alias Handin.Modules.Module

  def home(conn, _) do
    render(conn, :home)
  end

  def new(conn, %{"mode" => mode} = _params) do
    render(conn, :new,
      mode: mode,
      modules: Modules.fetch_module_names(),
      teachers: Accounts.fetch_all_teaher_emails()
    )
  end

  def create_module(conn, params) do
    # with {:ok, module} <- Modules.create_module(params),
    #      {:ok, _} <-
    #        Accounts.add_module(
    #          Accounts.get_user_by_email(params["teachers"]),
    #          module.id
    #        ) do
    #   if courses_ids = params["courses"] do
    #     for id <- courses_ids do
    #       Modules.add_module_to_course(%{module_id: module.id, course_id: id})
    #     end
    #   end

    #   conn
    #   |> put_flash(:info, "Module created successfully")
    #   |> redirect(to: ~p"/module")
    # else
    #   {:error, _changeset} ->
    #     conn
    #     |> put_flash(:error, "Module already exists")
    #     |> render("new.html",
    #       mode: "create",
    #       courses: Courses.fetch_course_names_and_id(),
    #       modules: Modules.fetch_module_names(),
    #       teachers: Accounts.fetch_all_teaher_emails()
    #     )
    # end
  end
end
