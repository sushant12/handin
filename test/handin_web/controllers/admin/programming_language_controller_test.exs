defmodule HandinWeb.Admin.ProgrammingLanguageControllerTest do
  use HandinWeb.ConnCase

  alias Handin.ProgrammingLanguages

  @create_attrs %{name: "some name", docker_file_url: "some docker_file_url"}
  @update_attrs %{name: "some updated name", docker_file_url: "some updated docker_file_url"}
  @invalid_attrs %{name: nil, docker_file_url: nil}

  def fixture(:programming_language) do
    {:ok, programming_language} = ProgrammingLanguages.create_programming_language(@create_attrs)
    programming_language
  end

  describe "index" do
    test "lists all programming_languages", %{conn: conn} do
      conn = get(conn, ~p"/admin/programming_languages")
      assert html_response(conn, 200) =~ "Programming languages"
    end
  end

  describe "new programming_language" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/programming_languages/new")
      assert html_response(conn, 200) =~ "New Programming language"
    end
  end

  describe "create programming_language" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/programming_languages", programming_language: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/programming_languages/#{id}"

      conn = get(conn, ~p"/admin/programming_languages/#{id}")
      assert html_response(conn, 200) =~ "Programming language Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/programming_languages", programming_language: @invalid_attrs
      assert html_response(conn, 200) =~ "New Programming language"
    end
  end

  describe "edit programming_language" do
    setup [:create_programming_language]

    test "renders form for editing chosen programming_language", %{
      conn: conn,
      programming_language: programming_language
    } do
      conn = get(conn, ~p"/admin/programming_languages/#{programming_language}/edit")
      assert html_response(conn, 200) =~ "Edit Programming language"
    end
  end

  describe "update programming_language" do
    setup [:create_programming_language]

    test "redirects when data is valid", %{conn: conn, programming_language: programming_language} do
      conn =
        put conn, ~p"/admin/programming_languages/#{programming_language}",
          programming_language: @update_attrs

      assert redirected_to(conn) == ~p"/admin/programming_languages/#{programming_language}"

      conn = get(conn, ~p"/admin/programming_languages/#{programming_language}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      programming_language: programming_language
    } do
      conn =
        put conn, ~p"/admin/programming_languages/#{programming_language}",
          programming_language: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit Programming language"
    end
  end

  describe "delete programming_language" do
    setup [:create_programming_language]

    test "deletes chosen programming_language", %{
      conn: conn,
      programming_language: programming_language
    } do
      conn = delete(conn, ~p"/admin/programming_languages/#{programming_language}")
      assert redirected_to(conn) == "/admin/programming_languages"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/programming_languages/#{programming_language}")
      end
    end
  end

  defp create_programming_language(_) do
    programming_language = fixture(:programming_language)
    {:ok, programming_language: programming_language}
  end
end
