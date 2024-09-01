defmodule Handin.Accounts.UserNotifier do
  import Swoosh.Email

  alias Handin.Mailer
  alias Handin.Accounts.User

  @spec send_temporary_password_emails(list(User.t())) :: :ok
  def send_temporary_password_emails(users) when is_list(users) do
    users
    |> Enum.each(fn user ->
      if user.temporary_password do
        deliver_temporary_password_email(user.email, user.temporary_password)
      end
    end)
  end

  def send_module_enrollment_emails(users, module_name) when is_list(users) do
    users
    |> Enum.each(fn user ->
      deliver_module_enrollment_email(user.email, module_name)
    end)
  end

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Handin", "hello@handin.org"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_temporary_password_email(email, temp_password) do
    deliver(email, "Temporary password", """
    Hello,

    Your account has been created with a temporary password: #{temp_password}

    Please log in and change your password as soon as possible.

    Interesting times!!!
    """)
  end

  def deliver_module_enrollment_email(email, module_name) do
    deliver(email, "You've been added to module: #{module_name}", """

    Hello #{email},

    You have been added to the module #{module_name}.

    Log in to your account to access the new module and its content.

    Interesting times!!!
    """)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """


    Hi #{user.email},

    You can confirm your account by clicking the button below:

    <a href="#{url}">Confirm</a>

    If you didn't create an account with us, please ignore this.

    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """


    Hi #{user.email},

    You can reset your password by clicking the button below:

    <a href="#{url}">Reset password</a>

    If you didn't request this change, please ignore this.

    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """


    Hi #{user.email},

    You can change your email by clicking the button below:

    <a href="#{url}">Change email</a>

    If you didn't request this change, please ignore this.

    """)
  end
end
