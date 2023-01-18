defmodule HandinWeb.CourseControllerTest do
  use HandinWeb.ConnCase, async: true

  import HandinWeb.Factory
  import Handin.AccountsFixtures

  setup do
    %{admin: insert(:admin), course_admin: insert(:course_admin), course: build(:course)}
  end

  describe "GET /admin/courses/new" do
    test "renders add course page", %{conn: conn, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(Routes.admin_course_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "<h2>Add new course</h2>"
      assert response =~ "<form "
      assert response =~ "<select "
    end
  end

  describe "POST /admin/courses" do
    test "adds course and includes the directors in the course", %{
      conn: conn,
      admin: admin,
      course_admin: course_admin,
      course: course
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(
          Routes.admin_course_path(conn, :create, %{
            "name" => course.name,
            "code" => course.code,
            "directors" => [Integer.to_string(course_admin.id)]
          })
        )

      user = Handin.Accounts.get_user!(course_admin.id)
      {:ok, course} = Handin.Courses.get_course_by_code(course.code)
      assert user.course_id == course.id
    end

    test "adding courses with same course code gives course already exists error", %{
      conn: conn,
      admin: admin,
      course_admin: course_admin,
      course: course
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(
          Routes.admin_course_path(conn, :create, %{
            "name" => course.name,
            "code" => course.code,
            "directors" => [Integer.to_string(course_admin.id)]
          })
        )
        |> post(
          Routes.admin_course_path(conn, :create, %{
            "name" => "Something else",
            "code" => course.code,
            "directors" => [Integer.to_string(course_admin.id)]
          })
        )

      response = html_response(conn, 200)
      assert response =~ "<p>Course already exists</p>"
    end
  end
end
