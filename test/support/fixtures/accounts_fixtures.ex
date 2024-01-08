defmodule Handin.AccountsFixtures do
  import Handin.UniversitiesFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Accounts` context.
  """

  def unique_user_email, do: "#{Enum.random(1..99)}@studentmail.ul.ie"
  def valid_user_password, do: "password1234"

  def valid_user_attributes(attrs \\ %{}) do
    university = if attrs[:university], do: attrs[:university], else: university_fixture().id

    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      university: university
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
