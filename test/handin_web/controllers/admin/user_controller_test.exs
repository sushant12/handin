defmodule HandinWeb.Admin.UserControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Accounts

  @create_attrs %{role: :student, email: "some email", hashed_password: "some hashed_password", confirmed_at: ~N[2024-09-09 05:50:00], university_id: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{role: :admin, email: "some updated email", hashed_password: "some updated hashed_password", confirmed_at: ~N[2024-09-10 05:50:00], university_id: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{role: nil, email: nil, hashed_password: nil, confirmed_at: nil, university_id: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, ~p"/admin/users"
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, ~p"/admin/users/new"
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/users", user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/users/#{id}"

      conn = get conn, ~p"/admin/users/#{id}"
      assert html_response(conn, 200) =~ "User Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/users", user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get conn, ~p"/admin/users/#{user}/edit"
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, ~p"/admin/users/#{user}", user: @update_attrs
      assert redirected_to(conn) == ~p"/admin/users/#{user}"

      conn = get conn, ~p"/admin/users/#{user}" 
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, ~p"/admin/users/#{user}", user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete conn, ~p"/admin/users/#{user}"
      assert redirected_to(conn) == "/admin/users"
      assert_error_sent 404, fn ->
        get conn, ~p"/admin/users/#{user}"
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
