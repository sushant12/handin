defmodule HandinWeb.UserSessionControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Accounts
  alias Handin.Repo

  describe "POST /users/log_in" do
    test "allows confirmed user to log in", %{conn: conn} do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)

      {encoded_token, user_token} = Handin.Accounts.UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token)

      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/modules"
    end

    test "prevents unconfirmed user from logging in and shows error message", %{conn: conn} do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Please confirm your account before logging in. Check your email for the confirmation link."
    end

    test "prevents unconfirmed lecturer from logging in", %{conn: conn} do
      attrs = %{
        email: "lecturer@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      {:ok, user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Please confirm your account before logging in. Check your email for the confirmation link."
    end

    test "allows confirmed user to log in after confirmation", %{conn: conn} do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Please confirm your account before logging in. Check your email for the confirmation link."

      {encoded_token, user_token} = Handin.Accounts.UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token)

      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/modules"
    end

    test "shows error for invalid email or password", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "nonexistent@studentmail.ul.ie", "password" => "wrongpassword"}
        })

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
    end
  end
end
