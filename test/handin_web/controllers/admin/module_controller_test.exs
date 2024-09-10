defmodule HandinWeb.Admin.ModuleControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Modules

  @create_attrs %{
    code: "some code",
    name: "some name",
    term: "some term",
    archived: true,
    deleted_at: ~U[2024-09-09 12:43:00Z],
    assignments_count: 42,
    students_count: 42
  }
  @update_attrs %{
    code: "some updated code",
    name: "some updated name",
    term: "some updated term",
    archived: false,
    deleted_at: ~U[2024-09-10 12:43:00Z],
    assignments_count: 43,
    students_count: 43
  }
  @invalid_attrs %{
    code: nil,
    name: nil,
    term: nil,
    archived: nil,
    deleted_at: nil,
    assignments_count: nil,
    students_count: nil
  }

  def fixture(:module) do
    {:ok, module} = Modules.create_module(@create_attrs)
    module
  end

  describe "index" do
    test "lists all modules", %{conn: conn} do
      conn = get(conn, ~p"/admin/modules")
      assert html_response(conn, 200) =~ "Modules"
    end
  end

  describe "new module" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/modules/new")
      assert html_response(conn, 200) =~ "New Module"
    end
  end

  describe "create module" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/modules", module: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/modules/#{id}"

      conn = get(conn, ~p"/admin/modules/#{id}")
      assert html_response(conn, 200) =~ "Module Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/modules", module: @invalid_attrs
      assert html_response(conn, 200) =~ "New Module"
    end
  end

  describe "edit module" do
    setup [:create_module]

    test "renders form for editing chosen module", %{conn: conn, module: module} do
      conn = get(conn, ~p"/admin/modules/#{module}/edit")
      assert html_response(conn, 200) =~ "Edit Module"
    end
  end

  describe "update module" do
    setup [:create_module]

    test "redirects when data is valid", %{conn: conn, module: module} do
      conn = put conn, ~p"/admin/modules/#{module}", module: @update_attrs
      assert redirected_to(conn) == ~p"/admin/modules/#{module}"

      conn = get(conn, ~p"/admin/modules/#{module}")
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, module: module} do
      conn = put conn, ~p"/admin/modules/#{module}", module: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Module"
    end
  end

  describe "delete module" do
    setup [:create_module]

    test "deletes chosen module", %{conn: conn, module: module} do
      conn = delete(conn, ~p"/admin/modules/#{module}")
      assert redirected_to(conn) == "/admin/modules"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/modules/#{module}")
      end
    end
  end

  defp create_module(_) do
    module = fixture(:module)
    {:ok, module: module}
  end
end
