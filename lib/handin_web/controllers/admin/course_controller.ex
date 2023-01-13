defmodule HandinWeb.Admin.CourseController do
  alias Handin.Accounts
  alias Handin.Courses
  alias Handin.Repo
  alias Handin.Accounts.User
  import Ecto.Query
  use HandinWeb, :controller

  def new(conn, _) do
    course_admins =
      User
      |> where(role: "course_admin")
      |> select([c], {c.email, c.id})
      |> Repo.all()

    render(conn, "new.html", error_message: nil, course_admins: course_admins)
  end

  def create(
        conn,
        %{"name" => _course_name, "code" => course_code, "directors" => director_ids} = params
      ) do
    with {:not_found, _} <- Courses.get_course_by_code(course_code),
         {:ok, course} <- Courses.create_course(params) do
      for id <- director_ids do
        Accounts.get_user!(String.to_integer(id))
        |> Accounts.add_course(course.id)
        |> Repo.update()
      end

      conn
      |> put_flash(:info, "Course created successfully")
      |> redirect(to: Routes.admin_page_path(conn, :index))
    else
      _ ->
        render(conn, "new.html", error_message: "Course already exists")
    end
  end
end
