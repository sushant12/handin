defmodule HandinWeb.AssignmentTestLiveTest do
  use HandinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Handin.AssignmentTestsFixtures

  @create_attrs %{command: "some command", name: "some name", marks: 120.5}
  @update_attrs %{command: "some updated command", name: "some updated name", marks: 456.7}
  @invalid_attrs %{command: nil, name: nil, marks: nil}

  defp create_assignment_test(_) do
    assignment_test = assignment_test_fixture()
    %{assignment_test: assignment_test}
  end

  describe "Index" do
    setup [:create_assignment_test]

    test "lists all assignment_tests", %{conn: conn, assignment_test: assignment_test} do
      {:ok, _index_live, html} = live(conn, ~p"/tests")

      assert html =~ "Listing Assignment tests"
      assert html =~ assignment_test.command
    end

    test "saves new assignment_test", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tests")

      assert index_live |> element("a", "New Assignment test") |> render_click() =~
               "New Assignment test"

      assert_patch(index_live, ~p"/tests/new")

      assert index_live
             |> form("#assignment_test-form", assignment_test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assignment_test-form", assignment_test: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tests")

      html = render(index_live)
      assert html =~ "Assignment test created successfully"
      assert html =~ "some command"
    end

    test "updates assignment_test in listing", %{conn: conn, assignment_test: assignment_test} do
      {:ok, index_live, _html} = live(conn, ~p"/tests")

      assert index_live
             |> element("#assignment_tests-#{assignment_test.id} a", "Edit")
             |> render_click() =~
               "Edit Assignment test"

      assert_patch(index_live, ~p"/tests/#{assignment_test}/edit")

      assert index_live
             |> form("#assignment_test-form", assignment_test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assignment_test-form", assignment_test: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tests")

      html = render(index_live)
      assert html =~ "Assignment test updated successfully"
      assert html =~ "some updated command"
    end

    test "deletes assignment_test in listing", %{conn: conn, assignment_test: assignment_test} do
      {:ok, index_live, _html} = live(conn, ~p"/tests")

      assert index_live
             |> element("#assignment_tests-#{assignment_test.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#assignment_tests-#{assignment_test.id}")
    end
  end

  describe "Show" do
    setup [:create_assignment_test]

    test "displays assignment_test", %{conn: conn, assignment_test: assignment_test} do
      {:ok, _show_live, html} = live(conn, ~p"/tests/#{assignment_test}")

      assert html =~ "Show Assignment test"
      assert html =~ assignment_test.command
    end

    test "updates assignment_test within modal", %{conn: conn, assignment_test: assignment_test} do
      {:ok, show_live, _html} = live(conn, ~p"/tests/#{assignment_test}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Assignment test"

      assert_patch(show_live, ~p"/tests/#{assignment_test}/show/edit")

      assert show_live
             |> form("#assignment_test-form", assignment_test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#assignment_test-form", assignment_test: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tests/#{assignment_test}")

      html = render(show_live)
      assert html =~ "Assignment test updated successfully"
      assert html =~ "some updated command"
    end
  end
end
