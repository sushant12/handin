defmodule HandinWeb.StudentsLiveTest do
  use HandinWeb.ConnCase
  import Phoenix.LiveViewTest
  import Handin.Factory
  import Swoosh.TestAssertions

  alias Handin.{Accounts, Modules, Repo}
  alias Handin.Modules.{ModulesInvitations, ModulesUsers}

  describe "inviting students to a module" do
    setup do
      lecturer = insert(:lecturer)
      module = insert(:module)

      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{lecturer: lecturer, module: module, conn: conn}
    end

    test "sends 'you have been added' email when inviting already registered student", %{
      conn: conn,
      module: module
    } do
      student_attrs = %{
        email: "1234567@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, student} = Accounts.register_user(student_attrs)

      {encoded_token, user_token} =
        Handin.Accounts.UserToken.build_email_token(student, "confirm")

      Repo.insert!(user_token)
      {:ok, _confirmed_student} = Accounts.confirm_user(encoded_token)

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/students")

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/students/new")

      view
      |> form("#student-form",
        user: %{
          first_name: "John",
          last_name: "Doe",
          email: student.email
        }
      )
      |> render_submit()

      assert Repo.get_by(ModulesUsers, user_id: student.id, module_id: module.id) != nil

      assert_email_sent(
        subject: "You've been added to module: #{module.name}",
        to: {student.email, student.email}
      )
    end

    test "creates pending invitation when inviting unregistered student", %{
      conn: conn,
      module: module
    } do
      unregistered_email = "9999999@studentmail.ul.ie"

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/students/new")

      view
      |> form("#student-form",
        user: %{
          first_name: "Jane",
          last_name: "Smith",
          email: unregistered_email
        }
      )
      |> render_submit()

      assert Accounts.get_user_by_email(unregistered_email) == nil

      invitation =
        Repo.get_by(ModulesInvitations, email: unregistered_email, module_id: module.id)

      assert invitation != nil
      assert invitation.email == unregistered_email
      assert invitation.module_id == module.id
    end

    test "adds student to module and removes invitation when unregistered student registers", %{
      module: module
    } do
      unregistered_email = "8888888@studentmail.ul.ie"

      {:ok, invitation} =
        Modules.add_modules_invitations(%{
          email: unregistered_email,
          module_id: module.id
        })

      assert invitation != nil

      student_attrs = %{
        email: unregistered_email,
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, student} = Accounts.register_user(student_attrs)

      Modules.check_and_add_new_user_modules_invitations(student)

      module_user = Repo.get_by(ModulesUsers, user_id: student.id, module_id: module.id)
      assert module_user != nil
      assert module_user.role == :student

      assert Repo.get(ModulesInvitations, invitation.id) == nil
    end

    test "sends 'you have been added' email only to registered students", %{
      conn: conn,
      module: module
    } do
      registered_student_attrs = %{
        email: "1111111@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, registered_student} = Accounts.register_user(registered_student_attrs)

      {encoded_token, user_token} =
        Handin.Accounts.UserToken.build_email_token(registered_student, "confirm")

      Repo.insert!(user_token)
      {:ok, _confirmed_student} = Accounts.confirm_user(encoded_token)

      unregistered_email = "2222222@studentmail.ul.ie"

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/students/new")

      view
      |> form("#student-form",
        user: %{
          first_name: "Registered",
          last_name: "Student",
          email: registered_student.email
        }
      )
      |> render_submit()

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/students/new")

      view
      |> form("#student-form",
        user: %{
          first_name: "Unregistered",
          last_name: "Student",
          email: unregistered_email
        }
      )
      |> render_submit()

      assert_email_sent(
        subject: "You've been added to module: #{module.name}",
        to: {registered_student.email, registered_student.email}
      )

      invitation =
        Repo.get_by(ModulesInvitations, email: unregistered_email, module_id: module.id)

      assert invitation != nil
    end
  end
end
