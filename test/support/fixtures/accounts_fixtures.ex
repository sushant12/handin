defmodule Handin.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@studentmail.ul.ie"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Handin.Accounts.register_user()

    user
  end

  def verify_user(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {:ok, user} =
      user
      |> Ecto.Changeset.change(confirmed_at: now)
      |> Handin.Repo.update()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
