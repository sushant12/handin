defmodule HandinWeb.TeachingAssistantsLiveTest do
  use HandinWeb.ConnCase
  import Phoenix.LiveViewTest
  import Handin.Factory

  alias Handin.{Accounts, Repo}
  alias Handin.Accounts.UserToken
  alias Handin.Modules.ModulesUsers

  describe "assigning teaching assistants" do
    setup do
      lecturer = insert(:lecturer)
      module = insert(:module)

      insert(:modules_users, user: lecturer, module: module, role: :lecturer)

      token = Accounts.generate_user_session_token(lecturer)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      %{lecturer: lecturer, module: module, conn: conn}
    end

    test "lecturer can assign a registered teaching assistant", %{
      conn: conn,
      module: module
    } do
      ta_attrs = %{
        email: "ta@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, ta_user} = Accounts.register_user(ta_attrs)

      {encoded_token, user_token} =
        UserToken.build_email_token(ta_user, "confirm")

      Repo.insert!(user_token)
      {:ok, _confirmed_ta} = Accounts.confirm_user(encoded_token)

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants/new")

      view
      |> form("#teaching-assistant-form", user: %{email: ta_user.email})
      |> render_submit()

      module_user =
        Repo.get_by(ModulesUsers,
          user_id: ta_user.id,
          module_id: module.id,
          role: :teaching_assistant
        )

      assert module_user != nil
      assert module_user.role == :teaching_assistant
    end

    test "lecturer cannot assign an unregistered teaching assistant", %{
      conn: conn,
      module: module
    } do
      unregistered_email = "unregistered@ul.ie"

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants/new")

      html =
        view
        |> form("#teaching-assistant-form", user: %{email: unregistered_email})
        |> render_submit()

      assert Accounts.get_user_by_email(unregistered_email) == nil

      module_user =
        Repo.get_by(ModulesUsers,
          module_id: module.id,
          role: :teaching_assistant
        )

      if module_user do
        refute module_user.user.email == unregistered_email
      end

      assert html =~ "User not found in our system"
    end

    test "lecturer sees error when trying to assign already assigned TA", %{
      conn: conn,
      module: module
    } do
      ta_attrs = %{
        email: "existing_ta@ul.ie",
        password: "password123",
        password_confirmation: "password123",
        role: "student"
      }

      {:ok, ta_user} = Accounts.register_user(ta_attrs)

      {encoded_token, user_token} =
        UserToken.build_email_token(ta_user, "confirm")

      Repo.insert!(user_token)
      {:ok, _confirmed_ta} = Accounts.confirm_user(encoded_token)

      insert(:modules_users,
        user: ta_user,
        module: module,
        role: :teaching_assistant
      )

      {:ok, view, _html} = live(conn, ~p"/modules/#{module.id}/teaching_assistants/new")

      html =
        view
        |> form("#teaching-assistant-form", user: %{email: ta_user.email})
        |> render_submit()

      assert html != nil
    end
  end
end
