defmodule Handin.AssignmentTestsTest do
  use Handin.DataCase

  alias Handin.AssignmentTests

  describe "assignment_tests" do
    alias Handin.AssignmentTests.AssignmentTest

    import Handin.AssignmentTestsFixtures

    @invalid_attrs %{command: nil, name: nil, marks: nil}

    test "list_assignment_tests/0 returns all assignment_tests" do
      assignment_test = assignment_test_fixture()
      assert AssignmentTests.list_assignment_tests() == [assignment_test]
    end

    test "get_assignment_test!/1 returns the assignment_test with given id" do
      assignment_test = assignment_test_fixture()
      assert AssignmentTests.get_assignment_test!(assignment_test.id) == assignment_test
    end

    test "create_assignment_test/1 with valid data creates a assignment_test" do
      valid_attrs = %{command: "some command", name: "some name", marks: 120.5}

      assert {:ok, %AssignmentTest{} = assignment_test} =
               AssignmentTests.create_assignment_test(valid_attrs)

      assert assignment_test.command == "some command"
      assert assignment_test.name == "some name"
      assert assignment_test.marks == 120.5
    end

    test "create_assignment_test/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssignmentTests.create_assignment_test(@invalid_attrs)
    end

    test "update_assignment_test/2 with valid data updates the assignment_test" do
      assignment_test = assignment_test_fixture()
      update_attrs = %{command: "some updated command", name: "some updated name", marks: 456.7}

      assert {:ok, %AssignmentTest{} = assignment_test} =
               AssignmentTests.update_assignment_test(assignment_test, update_attrs)

      assert assignment_test.command == "some updated command"
      assert assignment_test.name == "some updated name"
      assert assignment_test.marks == 456.7
    end

    test "update_assignment_test/2 with invalid data returns error changeset" do
      assignment_test = assignment_test_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AssignmentTests.update_assignment_test(assignment_test, @invalid_attrs)

      assert assignment_test == AssignmentTests.get_assignment_test!(assignment_test.id)
    end

    test "delete_assignment_test/1 deletes the assignment_test" do
      assignment_test = assignment_test_fixture()
      assert {:ok, %AssignmentTest{}} = AssignmentTests.delete_assignment_test(assignment_test)

      assert_raise Ecto.NoResultsError, fn ->
        AssignmentTests.get_assignment_test!(assignment_test.id)
      end
    end

    test "change_assignment_test/1 returns a assignment_test changeset" do
      assignment_test = assignment_test_fixture()
      assert %Ecto.Changeset{} = AssignmentTests.change_assignment_test(assignment_test)
    end
  end
end
