defmodule HandinWeb.ProgrammingLanguageLiveTest do
  use HandinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Handin.ProgrammingLanguagesFixtures

  @create_attrs %{name: "some name", docker_file_url: "some docker_file_url"}
  @update_attrs %{name: "some updated name", docker_file_url: "some updated docker_file_url"}
  @invalid_attrs %{name: nil, docker_file_url: nil}

  defp create_programming_language(_) do
    programming_language = programming_language_fixture()
    %{programming_language: programming_language}
  end

  describe "Index" do
    setup [:create_programming_language]

    test "lists all programming_languages", %{
      conn: conn,
      programming_language: programming_language
    } do
      {:ok, _index_live, html} = live(conn, ~p"/programming_languages")

      assert html =~ "Listing Programming languages"
      assert html =~ programming_language.name
    end

    test "saves new programming_language", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/programming_languages")

      assert index_live |> element("a", "New Programming language") |> render_click() =~
               "New Programming language"

      assert_patch(index_live, ~p"/programming_languages/new")

      assert index_live
             |> form("#programming_language-form", programming_language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#programming_language-form", programming_language: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/programming_languages")

      html = render(index_live)
      assert html =~ "Programming language created successfully"
      assert html =~ "some name"
    end

    test "updates programming_language in listing", %{
      conn: conn,
      programming_language: programming_language
    } do
      {:ok, index_live, _html} = live(conn, ~p"/programming_languages")

      assert index_live
             |> element("#programming_languages-#{programming_language.id} a", "Edit")
             |> render_click() =~
               "Edit Programming language"

      assert_patch(index_live, ~p"/programming_languages/#{programming_language}/edit")

      assert index_live
             |> form("#programming_language-form", programming_language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#programming_language-form", programming_language: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/programming_languages")

      html = render(index_live)
      assert html =~ "Programming language updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes programming_language in listing", %{
      conn: conn,
      programming_language: programming_language
    } do
      {:ok, index_live, _html} = live(conn, ~p"/programming_languages")

      assert index_live
             |> element("#programming_languages-#{programming_language.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#programming_languages-#{programming_language.id}")
    end
  end

  describe "Show" do
    setup [:create_programming_language]

    test "displays programming_language", %{
      conn: conn,
      programming_language: programming_language
    } do
      {:ok, _show_live, html} = live(conn, ~p"/programming_languages/#{programming_language}")

      assert html =~ "Show Programming language"
      assert html =~ programming_language.name
    end

    test "updates programming_language within modal", %{
      conn: conn,
      programming_language: programming_language
    } do
      {:ok, show_live, _html} = live(conn, ~p"/programming_languages/#{programming_language}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Programming language"

      assert_patch(show_live, ~p"/programming_languages/#{programming_language}/show/edit")

      assert show_live
             |> form("#programming_language-form", programming_language: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#programming_language-form", programming_language: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/programming_languages/#{programming_language}")

      html = render(show_live)
      assert html =~ "Programming language updated successfully"
      assert html =~ "some updated name"
    end
  end
end
