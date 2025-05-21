defmodule HandinWeb.UserSessionControllerTest do
  use HandinWeb.ConnCase, async: true

  alias Handin.Accounts
  alias Handin.Factory
  alias Handin.Repo
  alias Handin.Accounts.User

  @valid_attrs %{email: "test@example.com", password: "password123"}
  @invalid_attrs %{email: "invalid_email", password: "foo"}

  defp fixture(:user) do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    user
  end

  setup do
    Repo.delete_all(User)
    :ok
  end

  describe "POST /users/log_in" do
    test "logs in an existing user with valid credentials", %{conn: conn} do
      user = Factory.student_factory() |> Repo.insert!()
      conn = post(conn, Routes.user_session_path(conn, :create), %{"user" => %{"email" => user.email, "password" => "123456"}})
      assert redirected_to(conn) == Routes.user_module_path(conn, :index)
      assert get_flash(conn, :info) == "Welcome back!"
      assert get_session(conn, :user_token)
      assert conn.assigns.current_user.id == user.id
    end

    test "does not log in with invalid credentials", %{conn: conn} do
      user = Factory.student_factory() |> Repo.insert!()
      conn = post(conn, Routes.user_session_path(conn, :create), %{"user" => %{"email" => user.email, "password" => "wrongpassword"}})
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "Invalid email or password"
      assert !get_session(conn, :user_token)
      assert conn.assigns.current_user == nil
    end

    test "does not log in with an unregistered email", %{conn: conn} do
      conn = post(conn, Routes.user_session_path(conn, :create), %{"user" => %{"email" => "nonexistent@example.com", "password" => "anypassword"}})
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "Invalid email or password"
      assert !get_session(conn, :user_token)
      assert conn.assigns.current_user == nil
    end

    test "logs in an admin user and redirects to admin dashboard", %{conn: conn} do
      admin = Factory.admin_factory() |> Repo.insert!()
      conn = post(conn, Routes.user_session_path(conn, :create), %{"user" => %{"email" => admin.email, "password" => "123456"}})
      assert redirected_to(conn) == Routes.admin_user_path(conn, :index) # Assuming this route is /admin/users
      assert get_flash(conn, :info) == "Welcome back!"
      assert get_session(conn, :user_token)
      assert conn.assigns.current_user.id == admin.id
    end
  end

  describe "DELETE /users/log_out" do
    test "logs out a logged in user", %{conn: conn} do
      user = fixture(:user)
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert !get_session(conn, :user_token)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "does not error if no user is logged in", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert !get_session(conn, :user_token)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end
end
