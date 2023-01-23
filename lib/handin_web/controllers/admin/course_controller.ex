defmodule HandinWeb.Admin.CourseController do
  alias Handin.Accounts
  alias Handin.Courses

  use HandinWeb, :controller

  def new(conn, _) do
    render(conn, "new.html",
      error_message: nil,
      course_admins: Accounts.fetch_all_course_admins_email_and_id()
    )
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
      end

      conn
      |> put_flash(:info, "Course created successfully")
      |> redirect(to: Routes.admin_page_path(conn, :index))
    else
      _ ->
        render(conn, "new.html",
          error_message: "Course already exists",
          course_admins: Accounts.fetch_all_course_admins_email_and_id()
        )
    end
  end
end
