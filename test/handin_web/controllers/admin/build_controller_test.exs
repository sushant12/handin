defmodule HandinWeb.Admin.BuildControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Assignments

  @create_attrs %{
    status: :running,
    machine_id: "some machine_id",
    assignment_id: "7488a646-e31f-11e4-aace-600308960662",
    user_id: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    status: :failed,
    machine_id: "some updated machine_id",
    assignment_id: "7488a646-e31f-11e4-aace-600308960668",
    user_id: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{status: nil, machine_id: nil, assignment_id: nil, user_id: nil}

  def fixture(:build) do
    {:ok, build} = Assignments.create_build(@create_attrs)
    build
  end

  describe "index" do
    test "lists all builds", %{conn: conn} do
      conn = get(conn, ~p"/admin/builds")
      assert html_response(conn, 200) =~ "Builds"
    end
  end

  describe "new build" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/builds/new")
      assert html_response(conn, 200) =~ "New Build"
    end
  end

  describe "create build" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/builds", build: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/builds/#{id}"

      conn = get(conn, ~p"/admin/builds/#{id}")
      assert html_response(conn, 200) =~ "Build Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/builds", build: @invalid_attrs
      assert html_response(conn, 200) =~ "New Build"
    end
  end

  describe "edit build" do
    setup [:create_build]

    test "renders form for editing chosen build", %{conn: conn, build: build} do
      conn = get(conn, ~p"/admin/builds/#{build}/edit")
      assert html_response(conn, 200) =~ "Edit Build"
    end
  end

  describe "update build" do
    setup [:create_build]

    test "redirects when data is valid", %{conn: conn, build: build} do
      conn = put conn, ~p"/admin/builds/#{build}", build: @update_attrs
      assert redirected_to(conn) == ~p"/admin/builds/#{build}"

      conn = get(conn, ~p"/admin/builds/#{build}")
      assert html_response(conn, 200) =~ "some updated machine_id"
    end

    test "renders errors when data is invalid", %{conn: conn, build: build} do
      conn = put conn, ~p"/admin/builds/#{build}", build: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Build"
    end
  end

  describe "delete build" do
    setup [:create_build]

    test "deletes chosen build", %{conn: conn, build: build} do
      conn = delete(conn, ~p"/admin/builds/#{build}")
      assert redirected_to(conn) == "/admin/builds"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/builds/#{build}")
      end
    end
  end

  defp create_build(_) do
    build = fixture(:build)
    {:ok, build: build}
  end
end
