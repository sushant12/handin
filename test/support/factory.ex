defmodule HandinWeb.Factory do
  alias Handin.Repo
  alias Handin.Accounts.User
  alias Handin.Modules.Module
  alias Handin.Universities.University

  defp valid_user_password, do: "hello world!"
  @now NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  @unique_num System.unique_integer()

  def build(:admin) do
    %User{
      email: "admin@admin.com",
      hashed_password: Bcrypt.hash_pwd_salt("admin"),
      confirmed_at: @now,
      role: "admin"
    }
  end

  def build(:user_unconfirmed) do
    %User{
      email: "user#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      role: "student",
    }
  end

  def build(:module) do
    %Module{
      name: "M#{@unique_num}",
      code: "CS#{@unique_num}"
    }
  end

  def build(:lecturer) do
    %User{
      email: "lecturer#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "lecturer"
    }
  end

  def build(:student_unconfirmed) do
    %User{
      email: "student#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      role: "student"
    }
  end

  def build(:student) do
    %User{
      email: "student#{@unique_num}@studentmail.ul.ie",
      hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
      confirmed_at: @now,
      role: "student"
    }
  end

  def build(:university) do
    %University{
      name: "U#{@unique_num}",
      student_email_regex: "^\\d+@studentmail.ul.ie$"
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
