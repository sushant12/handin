defmodule HandinWeb.UserSessionController do
  use HandinWeb, :controller

  alias Handin.Accounts
  alias Handin.Accounts.User
  alias HandinWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(
      conn,
      params,
      "Account created successfully! Please confirm your email before logging in"
    )
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> put_user_return_to(user)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  defp put_user_return_to(conn, %User{role: :admin}),
    do: put_session(conn, :user_return_to, ~p"/admin/users")

  defp put_user_return_to(conn, _user), do: put_session(conn, :user_return_to, ~p"/modules")
end
