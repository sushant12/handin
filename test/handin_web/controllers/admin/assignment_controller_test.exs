defmodule HandinWeb.Admin.AssignmentControllerTest do
  use HandinWeb.ConnCase

  alias Handin.Assignments

  @create_attrs %{
    name: "some name",
    max_attempts: 42,
    start_date: ~N[2024-09-09 15:24:00],
    due_date: ~N[2024-09-09 15:24:00],
    run_script: "some run_script",
    enable_max_attempts: true,
    enable_total_marks: true,
    total_marks: 42,
    enable_cutoff_date: true,
    cutoff_date: ~N[2024-09-09 15:24:00],
    enable_penalty_per_day: true,
    penalty_per_day: 120.5,
    enable_attempt_marks: true,
    attempt_marks: 42,
    enable_test_output: true
  }
  @update_attrs %{
    name: "some updated name",
    max_attempts: 43,
    start_date: ~N[2024-09-10 15:24:00],
    due_date: ~N[2024-09-10 15:24:00],
    run_script: "some updated run_script",
    enable_max_attempts: false,
    enable_total_marks: false,
    total_marks: 43,
    enable_cutoff_date: false,
    cutoff_date: ~N[2024-09-10 15:24:00],
    enable_penalty_per_day: false,
    penalty_per_day: 456.7,
    enable_attempt_marks: false,
    attempt_marks: 43,
    enable_test_output: false
  }
  @invalid_attrs %{
    name: nil,
    max_attempts: nil,
    start_date: nil,
    due_date: nil,
    run_script: nil,
    enable_max_attempts: nil,
    enable_total_marks: nil,
    total_marks: nil,
    enable_cutoff_date: nil,
    cutoff_date: nil,
    enable_penalty_per_day: nil,
    penalty_per_day: nil,
    enable_attempt_marks: nil,
    attempt_marks: nil,
    enable_test_output: nil
  }

  def fixture(:assignment) do
    {:ok, assignment} = Assignments.create_assignment(@create_attrs)
    assignment
  end

  describe "index" do
    test "lists all assignments", %{conn: conn} do
      conn = get(conn, ~p"/admin/assignments")
      assert html_response(conn, 200) =~ "Assignments"
    end
  end

  describe "new assignment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/assignments/new")
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "create assignment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/admin/assignments", assignment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/admin/assignments/#{id}"

      conn = get(conn, ~p"/admin/assignments/#{id}")
      assert html_response(conn, 200) =~ "Assignment Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/admin/assignments", assignment: @invalid_attrs
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "edit assignment" do
    setup [:create_assignment]

    test "renders form for editing chosen assignment", %{conn: conn, assignment: assignment} do
      conn = get(conn, ~p"/admin/assignments/#{assignment}/edit")
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "update assignment" do
    setup [:create_assignment]

    test "redirects when data is valid", %{conn: conn, assignment: assignment} do
      conn = put conn, ~p"/admin/assignments/#{assignment}", assignment: @update_attrs
      assert redirected_to(conn) == ~p"/admin/assignments/#{assignment}"

      conn = get(conn, ~p"/admin/assignments/#{assignment}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, assignment: assignment} do
      conn = put conn, ~p"/admin/assignments/#{assignment}", assignment: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "delete assignment" do
    setup [:create_assignment]

    test "deletes chosen assignment", %{conn: conn, assignment: assignment} do
      conn = delete(conn, ~p"/admin/assignments/#{assignment}")
      assert redirected_to(conn) == "/admin/assignments"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/assignments/#{assignment}")
      end
    end
  end

  defp create_assignment(_) do
    assignment = fixture(:assignment)
    {:ok, assignment: assignment}
  end
end
