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
      module_struct: module_struct,
      teacher: teacher
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :create_module), %{
          "name" => module_struct.name,
          "teacher" => teacher.email
        })

      %{"info" => info} = get_flash(conn)
      inserted_module = Handin.Repo.get_by(Module, name: module_struct.name)

      assert info == "Module created successfully"
      assert inserted_module.name == module_struct.name
    end

    test "creates a module with course", %{
      conn: conn,
      user: user,
      module_struct: module_struct,
      teacher: teacher,
      course: course
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :create_module), %{
          "name" => module_struct.name,
          "teacher" => teacher.email,
          "courses" => [course.id]
        })

      %{"info" => info} = get_flash(conn)
      inserted_module = Handin.Repo.get_by(Module, name: module_struct.name)
      %{teacher: inserted_teacher} = Handin.Repo.preload(inserted_module, :teacher)

      assert info == "Module created successfully"
      assert inserted_module.name == module_struct.name
      assert inserted_teacher.id == teacher.id
    end

    test "creating existing module gives error", %{
      conn: conn,
      user: user,
      module: module,
      teacher: teacher,
      course: course
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :create_module), %{
          "name" => module.name,
          "teacher" => teacher.email,
          "courses" => [course.id]
        })

      %{"error" => error} = get_flash(conn)

      assert error == "Module already exists"
    end

    test "add an existing module to course", %{
      conn: conn,
      user: user,
      module: module,
      course: course
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :add_existing), %{
          "modules" => module.name,
          "courses" => [course.id]
        })

      %{"info" => info} = get_flash(conn)
      inserted_module = Handin.Repo.get_by(Module, name: module.name)
      %{courses: courses} = Handin.Repo.preload(inserted_module, :courses)

      assert course in courses
      assert info == "Module added successfully"
    end

    test "add an module to already added course", %{
      conn: conn,
      user: user,
      module: module,
      course: course
    } do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.module_path(conn, :add_existing), %{
          "modules" => module.name,
          "courses" => [course.id]
        })|> post(Routes.module_path(conn, :add_existing), %{
          "modules" => module.name,
          "courses" => [course.id]
        })

      %{"error" => error} = get_flash(conn)

      assert error == "Module was already added"
    end
  end
end
