defmodule HandinWeb.UserSessionController do
  use HandinWeb, :controller

  alias Handin.Accounts
  alias Handin.Accounts.User
  alias HandinWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password),
         true <- User.verified?(user) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> UserAuth.log_in_user(user, user_params)
    else
      # TODO: implement verify email error
      # false ->
      #   render(conn, :new, error_message: "Please verify your email before logging in")
      _ ->
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
