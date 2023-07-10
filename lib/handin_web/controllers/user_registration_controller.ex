defmodule HandinWeb.UserRegistrationController do
  use HandinWeb, :controller

  alias Handin.Accounts
  alias Handin.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "User created successfully. Please verify your account before signing in.")
        |> redirect(to: "/users/log_in")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
