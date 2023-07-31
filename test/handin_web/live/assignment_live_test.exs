defmodule HandinWeb.AssignmentLiveTest do
  use HandinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Handin.AssignmentsFixtures

  @create_attrs %{
    name: "some name",
    max_attempts: 42,
    total_marks: 42,
    start_date: "2023-07-22T12:41:00Z",
    due_date: "2023-07-22T12:41:00Z",
    cutoff_date: "2023-07-22T12:41:00Z",
    penalty_per_day: 120.5
  }
  @update_attrs %{
    name: "some updated name",
    max_attempts: 43,
    total_marks: 43,
    start_date: "2023-07-23T12:41:00Z",
    due_date: "2023-07-23T12:41:00Z",
    cutoff_date: "2023-07-23T12:41:00Z",
    penalty_per_day: 456.7
  }
  @invalid_attrs %{
    name: nil,
    max_attempts: nil,
    total_marks: nil,
    start_date: nil,
    due_date: nil,
    cutoff_date: nil,
    penalty_per_day: nil
  }

  defp create_assignment(_) do
    assignment = assignment_fixture()
    %{assignment: assignment}
  end

  describe "Index" do
    setup [:create_assignment]

    test "lists all assignments", %{conn: conn, assignment: assignment} do
      {:ok, _index_live, html} = live(conn, ~p"/assignments")

      assert html =~ "Listing Assignments"
      assert html =~ assignment.name
    end

    test "saves new assignment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/assignments")

      assert index_live |> element("a", "New Assignment") |> render_click() =~
               "New Assignment"

      assert_patch(index_live, ~p"/assignments/new")

      assert index_live
             |> form("#assignment-form", assignment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assignment-form", assignment: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/assignments")

      html = render(index_live)
      assert html =~ "Assignment created successfully"
      assert html =~ "some name"
    end

    test "updates assignment in listing", %{conn: conn, assignment: assignment} do
      {:ok, index_live, _html} = live(conn, ~p"/assignments")

      assert index_live |> element("#assignments-#{assignment.id} a", "Edit") |> render_click() =~
               "Edit Assignment"

      assert_patch(index_live, ~p"/assignments/#{assignment}/edit")

      assert index_live
             |> form("#assignment-form", assignment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assignment-form", assignment: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/assignments")

      html = render(index_live)
      assert html =~ "Assignment updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes assignment in listing", %{conn: conn, assignment: assignment} do
      {:ok, index_live, _html} = live(conn, ~p"/assignments")

      assert index_live |> element("#assignments-#{assignment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#assignments-#{assignment.id}")
    end
  end

  describe "Show" do
    setup [:create_assignment]

    test "displays assignment", %{conn: conn, assignment: assignment} do
      {:ok, _show_live, html} = live(conn, ~p"/assignments/#{assignment}")

      assert html =~ "Show Assignment"
      assert html =~ assignment.name
    end

    test "updates assignment within modal", %{conn: conn, assignment: assignment} do
      {:ok, show_live, _html} = live(conn, ~p"/assignments/#{assignment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Assignment"

      assert_patch(show_live, ~p"/assignments/#{assignment}/show/edit")

      assert show_live
             |> form("#assignment-form", assignment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#assignment-form", assignment: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/assignments/#{assignment}")

      html = render(show_live)
      assert html =~ "Assignment updated successfully"
      assert html =~ "some updated name"
    end
  end
end
