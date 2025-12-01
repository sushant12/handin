defmodule Handin.AccountsTest do
  use Handin.DataCase

  alias Handin.Accounts
  alias Handin.Accounts.{User, UserToken}
  alias Handin.Repo

  describe "register_user/1" do
    test "creates a student with valid student email" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert user.email == "1232456@studentmail.ul.ie"
      assert user.role == :student
      assert user.hashed_password
      refute user.password
      assert is_nil(user.confirmed_at)
    end

    test "creates a lecturer with valid lecturer email" do
      attrs = %{
        email: "name.lastname@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert user.email == "name.lastname@ul.ie"
      assert user.role == :lecturer
      assert user.hashed_password
      refute user.password
      assert is_nil(user.confirmed_at)
    end

    test "rejects student email with wrong domain" do
      attrs = %{
        email: "1232456@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "please use your student email address" in errors_on(changeset).email
    end

    test "rejects student email without digits before @studentmail.ul.ie" do
      attrs = %{
        email: "student@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "please use your student email address" in errors_on(changeset).email
    end

    test "rejects student email with invalid domain format" do
      attrs = %{
        email: "1232456@studnetmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "please use your student email address" in errors_on(changeset).email
    end

    test "rejects student email with generic domain" do
      attrs = %{
        email: "1232456@gmail.com",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "please use your student email address" in errors_on(changeset).email
    end

    test "rejects lecturer email with wrong domain" do
      attrs = %{
        email: "name.lastname@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "must be in the format username@ul.ie" in errors_on(changeset).email
    end

    test "rejects lecturer email with generic domain" do
      attrs = %{
        email: "name.lastname@gmail.com",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "must be in the format username@ul.ie" in errors_on(changeset).email
    end

    test "accepts lecturer email with various valid formats" do
      valid_emails = [
        "name.lastname@ul.ie",
        "firstname@ul.ie",
        "user_name@ul.ie",
        "user-name@ul.ie",
        "user123@ul.ie",
        "first.last@ul.ie"
      ]

      for email <- valid_emails do
        attrs = %{
          email: email,
          password: "password123",
          password_confirmation: "password123",
          role: "lecturer"
        }

        assert {:ok, %User{} = user} = Accounts.register_user(attrs)
        assert user.email == email
        assert user.role == :lecturer
      end
    end

    test "accepts student email with various digit formats" do
      valid_emails = [
        "1232456@studentmail.ul.ie",
        "1@studentmail.ul.ie",
        "123456789@studentmail.ul.ie",
        "999999@studentmail.ul.ie"
      ]

      for email <- valid_emails do
        attrs = %{
          email: email,
          password: "password123",
          password_confirmation: "password123",
          role: "student"
        }

        assert {:ok, %User{} = user} = Accounts.register_user(attrs)
        assert user.email == email
        assert user.role == :student
      end
    end

    test "rejects duplicate email" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, _user} = Accounts.register_user(attrs)

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "requires password confirmation to match" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "different",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "does not match password" in errors_on(changeset).password_confirmation
    end

    test "requires minimum password length" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "1234",
        password_confirmation: "1234",
        role: "student"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "should be at least 5 character(s)" in errors_on(changeset).password
    end

    test "rejects admin role during registration" do
      attrs = %{
        email: "admin@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "admin"
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "is invalid" in errors_on(changeset).role
    end

    test "rejects admin role with atom value during registration" do
      attrs = %{
        email: "admin@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: :admin
      }

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "is invalid" in errors_on(changeset).role
    end

    test "only allows student or lecturer role during registration" do
      student_attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = student} = Accounts.register_user(student_attrs)
      assert student.role == :student

      lecturer_attrs = %{
        email: "lecturer@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      assert {:ok, %User{} = lecturer} = Accounts.register_user(lecturer_attrs)
      assert lecturer.role == :lecturer
    end
  end

  describe "registration_changeset/2" do
    test "validates student email format" do
      changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "1232456@studentmail.ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "student"
        })

      assert changeset.valid?
    end

    test "validates lecturer email format" do
      changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "name.lastname@ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "lecturer"
        })

      assert changeset.valid?
    end

    test "invalidates student email with wrong domain" do
      changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "1232456@ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "student"
        })

      refute changeset.valid?
      assert "please use your student email address" in errors_on(changeset).email
    end

    test "invalidates lecturer email with wrong domain" do
      changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "name.lastname@studentmail.ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "lecturer"
        })

      refute changeset.valid?
      assert "must be in the format username@ul.ie" in errors_on(changeset).email
    end

    test "rejects admin role in registration changeset" do
      changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "admin@ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        })

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).role
    end

    test "only accepts student or lecturer role in registration changeset" do
      student_changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "1232456@studentmail.ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "student"
        })

      assert student_changeset.valid?

      lecturer_changeset =
        %User{}
        |> User.registration_changeset(%{
          email: "lecturer@ul.ie",
          password: "password123",
          password_confirmation: "password123",
          role: "lecturer"
        })

      assert lecturer_changeset.valid?
    end
  end

  describe "confirm_user/1" do
    test "sets confirmed_at when user confirms with valid token" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      assert {:ok, confirmed_user} = Accounts.confirm_user(encoded_token)
      assert confirmed_user.id == user.id
      assert confirmed_user.confirmed_at != nil
      assert %NaiveDateTime{} = confirmed_user.confirmed_at

      confirmed_user_from_db = Repo.get!(User, user.id)
      assert confirmed_user_from_db.confirmed_at != nil
    end

    test "sets confirmed_at for lecturer when confirming with valid token" do
      attrs = %{
        email: "name.lastname@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "lecturer"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      assert {:ok, confirmed_user} = Accounts.confirm_user(encoded_token)
      assert confirmed_user.id == user.id
      assert confirmed_user.confirmed_at != nil
      assert %NaiveDateTime{} = confirmed_user.confirmed_at
    end

    test "does not confirm user with invalid token" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      assert :error = Accounts.confirm_user("invalid_token")

      user_from_db = Repo.get!(User, user.id)
      assert is_nil(user_from_db.confirmed_at)
    end

    test "does not confirm user with expired token" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      inserted_token = Repo.insert!(user_token)

      expired_date =
        NaiveDateTime.utc_now() |> NaiveDateTime.add(-8, :day) |> NaiveDateTime.truncate(:second)

      Repo.update_all(
        from(t in UserToken, where: t.id == ^inserted_token.id),
        set: [inserted_at: expired_date]
      )

      assert :error = Accounts.confirm_user(encoded_token)

      user_from_db = Repo.get!(User, user.id)
      assert is_nil(user_from_db.confirmed_at)
    end

    test "deletes confirmation token after successful confirmation" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      inserted_token = Repo.insert!(user_token)

      assert Repo.get(UserToken, inserted_token.id) != nil

      assert {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token)

      assert Repo.get(UserToken, inserted_token.id) == nil
    end

    test "cannot confirm already confirmed user" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)

      {encoded_token1, user_token1} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token1)
      assert {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token1)

      {encoded_token2, user_token2} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token2)

      assert {:ok, already_confirmed_user} = Accounts.confirm_user(encoded_token2)
      assert already_confirmed_user.confirmed_at != nil

      assert {:error, :already_confirmed} =
               Accounts.deliver_user_confirmation_instructions(
                 already_confirmed_user,
                 fn _token -> "http://example.com/confirm" end
               )
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    test "creates confirmation token for unconfirmed user" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      assert {:ok, _} =
               Accounts.deliver_user_confirmation_instructions(
                 user,
                 fn token -> "http://example.com/confirm/#{token}" end
               )

      tokens =
        Repo.all(from(t in UserToken, where: t.user_id == ^user.id and t.context == "confirm"))

      assert length(tokens) == 1
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "returns user for confirmed user with correct password" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token)

      found_user = Accounts.get_user_by_email_and_password(user.email, "password123")
      assert found_user != nil
      assert found_user.id == user.id
      assert found_user.confirmed_at != nil
    end

    test "returns user for unconfirmed user with correct password" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)
      assert is_nil(user.confirmed_at)

      found_user = Accounts.get_user_by_email_and_password(user.email, "password123")
      assert found_user != nil
      assert found_user.id == user.id
      assert is_nil(found_user.confirmed_at)
    end

    test "returns nil for incorrect password" do
      attrs = %{
        email: "1232456@studentmail.ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, user} = Accounts.register_user(attrs)

      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      {:ok, _confirmed_user} = Accounts.confirm_user(encoded_token)

      assert Accounts.get_user_by_email_and_password(user.email, "wrongpassword") == nil
    end

    test "returns nil for non-existent email" do
      assert Accounts.get_user_by_email_and_password(
               "nonexistent@studentmail.ul.ie",
               "password123"
             ) == nil
    end
  end
end
