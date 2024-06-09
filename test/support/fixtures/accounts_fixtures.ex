defmodule Handin.AccountsFixtures do
  import Handin.UniversitiesFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Accounts` context.
  """

  def unique_user_email, do: "#{Enum.random(1..99)}@studentmail.ul.ie"
  def valid_user_password, do: "password1234"

  def valid_user_attributes(attrs \\ %{}) do
    university_id =
      if attrs[:university], do: attrs[:university].id, else: university_fixture().id

    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      university_id: university_id
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Handin.Accounts.register_user()

    user
  end

  def lecturer_fixture() do
    %Handin.Accounts.User{
      email: unique_user_email(),
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      role: :lecturer,
      confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }
    |> Handin.Repo.insert!()
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
