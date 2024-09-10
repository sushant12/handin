defmodule HandinWeb.Admin.UniversityControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Universities

  @create_attrs %{name: "some name", student_email_regex: "some student_email_regex", timezone: "some timezone"}
  @update_attrs %{name: "some updated name", student_email_regex: "some updated student_email_regex", timezone: "some updated timezone"}
  @invalid_attrs %{name: nil, student_email_regex: nil, timezone: nil}

  def fixture(:university) do
    {:ok, university} = Universities.create_university(@create_attrs)
    university
  end

  describe "index" do
    test "lists all universities", %{conn: conn} do
      conn = get conn, ~p"/admin/universities"
      assert html_response(conn, 200) =~ "Universities"
    end
  end

  describe "new university" do
    test "renders form", %{conn: conn} do
      conn = get conn, ~p"/admin/universities/new"
      assert html_response(conn, 200) =~ "New University"
    end
  end

  describe "create university" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/universities", university: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/universities/#{id}"

      conn = get conn, ~p"/admin/universities/#{id}"
      assert html_response(conn, 200) =~ "University Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/universities", university: @invalid_attrs
      assert html_response(conn, 200) =~ "New University"
    end
  end

  describe "edit university" do
    setup [:create_university]

    test "renders form for editing chosen university", %{conn: conn, university: university} do
      conn = get conn, ~p"/admin/universities/#{university}/edit"
      assert html_response(conn, 200) =~ "Edit University"
    end
  end

  describe "update university" do
    setup [:create_university]

    test "redirects when data is valid", %{conn: conn, university: university} do
      conn = put conn, ~p"/admin/universities/#{university}", university: @update_attrs
      assert redirected_to(conn) == ~p"/admin/universities/#{university}"

      conn = get conn, ~p"/admin/universities/#{university}" 
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, university: university} do
      conn = put conn, ~p"/admin/universities/#{university}", university: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit University"
    end
  end

  describe "delete university" do
    setup [:create_university]

    test "deletes chosen university", %{conn: conn, university: university} do
      conn = delete conn, ~p"/admin/universities/#{university}"
      assert redirected_to(conn) == "/admin/universities"
      assert_error_sent 404, fn ->
        get conn, ~p"/admin/universities/#{university}"
      end
    end
  end

  defp create_university(_) do
    university = fixture(:university)
    {:ok, university: university}
  end
end
