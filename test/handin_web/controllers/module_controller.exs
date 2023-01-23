defmodule HandinWeb.ModuleControllerTest do
  use HandinWeb.ConnCase, async: true
  import HandinWeb.Factory
  import Handin.AccountsFixtures

  alias Handin.Modules.Module

  setup do
    %{
      user: user_fixture(),
      course: insert(:course),
      teacher: insert(:teacher),
      module: insert(:module),
      module_struct: build(:module)
    }
  end

  describe "GET /module" do
    test "renders index page", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.module_path(conn, :index))

      response = html_response(conn, 200)
      assert response =~ "Create a module"
      assert response =~ "Add existing module to course"
    end
  end

  describe "GET /module/:mode" do
    test "renders new page for creating new module", %{
      conn: conn,
      user: user,
      course: course,
      teacher: teacher
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.module_path(conn, :new, "create"))

      response = html_response(conn, 200)
      assert response =~ "<h1 class=\"font-medium text-3xl\">Create Module</h1>"
      assert response =~ "Name"
      assert response =~ teacher.email
      assert response =~ course.name
    end

    test "renders new page for adding existing module to courses", %{
      conn: conn,
      user: user,
      course: course,
      teacher: teacher,
      module: module
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.module_path(conn, :new, "add_existing"))

      response = html_response(conn, 200)
      assert response =~ "Add Module to Courses"
      assert response =~ "Modules"
      assert response =~ "<option value=\"#{module.name}\">#{module.name}</option></select>"
      assert response =~ "<option value=\"#{course.id}\">#{course.name}</option>"
    end
  end

  describe "POST /module/modes" do
    test "creates a new module without course", %{
      conn: conn,
      user: user,
      module_struct: module_struct
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :create_module), %{
          "name" => module_struct.name
        })

      %{"info" => info} = get_flash(conn)
      inserted_module = Handin.Repo.get_by(Module, name: module_struct.name)

      assert info == "Module created successfully"
      assert inserted_module.name == module_struct.name
    end
  end
end
