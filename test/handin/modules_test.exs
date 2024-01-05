defmodule Handin.ModulesTest do
  use Handin.DataCase

  import Handin.{ModulesFixtures, AccountsFixtures, UniversitiesFixtures, AssignmentsFixtures}
  alias Handin.{Modules, Accounts}
  alias Handin.Modules.Module

  @invalid_attrs %{name: nil, code: nil}

  setup do
    university = university_fixture()
    lecturer = lecturer_fixture()

    %{
      lecturer: lecturer,
      university: university,
      user: user_fixture(%{university: university.id}),
      module: module_fixture(%{user_id: lecturer.id})
    }
  end

  describe "module" do
    test "list_module/0 returns all module", %{module: module} do
      assert Modules.list_module() == [module]
    end

    test "get_module!/1 returns the module with given id", %{module: module} do
      module = module |> Handin.Repo.preload(:assignments)
      assert Modules.get_module!(module.id) == module
    end

    test "create_module/1 with valid data creates a module", %{user: user} do
      valid_attrs = %{name: "some name", code: "CS100"}

      assert {:ok, %Module{} = module} = Modules.create_module(valid_attrs, user.id)
      assert module.name == "some name"
      assert module.code == "CS100"
    end

    test "create_module/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Modules.create_module(@invalid_attrs, user.id)
    end

    test "update_module/2 with valid data updates the module", %{module: module} do
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Module{} = module} = Modules.update_module(module, update_attrs)
      assert module.name == "some updated name"
    end

    test "update_module/2 with invalid data returns error changeset", %{module: module} do
      module = module |> Handin.Repo.preload(:assignments)
      assert {:error, %Ecto.Changeset{}} = Modules.update_module(module, @invalid_attrs)
      assert module == Modules.get_module!(module.id)
    end

    test "delete_module/1 deletes the module", %{module: module} do
      assert {:ok, %Module{}} = Modules.delete_module(module)
      assert_raise Ecto.NoResultsError, fn -> Modules.get_module!(module.id) end
    end

    test "change_module/1 returns a module changeset", %{module: module} do
      assert %Ecto.Changeset{} = Modules.change_module(module)
    end

    test "fetch_module_names/1 returns list of module names", %{lecturer: lecturer} do
      module_fixture(%{user_id: lecturer.id})
      module_fixture(%{user_id: lecturer.id})
      module_fixture(%{user_id: lecturer.id})

      # 4 because of the module from setup as well
      assert Enum.count(Modules.fetch_module_names()) == 4
    end
  end

  describe "add_member/2" do
    test "adds a student to the module", %{university: university, module: module} do
      user1 = user_fixture(%{university: university.id})
      Modules.add_member(%{user_id: user1.id, module_id: module.id})

      user1 = Accounts.get_user!(user1.id)

      assert user1.modules == [module]
    end

    test "adds a students to multiple module", %{lecturer: lecturer, university: university} do
      module1 = module_fixture(%{user_id: lecturer.id})
      module2 = module_fixture(%{user_id: lecturer.id})
      user1 = user_fixture(%{university: university.id})
      Modules.add_member(%{user_id: user1.id, module_id: module1.id})
      Modules.add_member(%{user_id: user1.id, module_id: module2.id})

      user1 = Accounts.get_user!(user1.id)

      assert Enum.count(user1.modules) == 2
    end
  end

  describe "get_students/1" do
    test "returns a list of students", %{university: university, module: module} do
      user1 = user_fixture(%{university: university.id})
      user2 = user_fixture(%{university: university.id})
      _user3 = user_fixture(%{university: university.id})

      Modules.add_member(%{user_id: user1.id, module_id: module.id})
      Modules.add_member(%{user_id: user2.id, module_id: module.id})

      assert Enum.count(Modules.get_students(module.id)) == 2
    end
  end

  describe "get_students_count/1" do
    test "returns the number of students", %{lecturer: lecturer, university: university} do
      module = module_fixture(%{user_id: lecturer.id})
      user1 = user_fixture(%{university: university.id})
      user2 = user_fixture(%{university: university.id})
      _user3 = user_fixture(%{university: university.id})

      Modules.add_member(%{user_id: user1.id, module_id: module.id})
      Modules.add_member(%{user_id: user2.id, module_id: module.id})

      assert Modules.get_students_count(module.id) == 2
    end
  end

  describe "remove_user_from_module/2" do
    test "removes a user from the module", %{module: module, university: university} do
      user1 = user_fixture(%{university: university.id})
      Modules.add_member(%{user_id: user1.id, module_id: module.id})

      user1 = Accounts.get_user!(user1.id)

      assert user1.modules == [module]

      {:ok, _} = Modules.remove_user_from_module(user1.id, module.id)

      user1 = Accounts.get_user!(user1.id)

      assert user1.modules == []
    end
  end

  describe "modules_invitations" do
    alias Handin.Modules.ModulesInvitations

    test "change_modules_invitations/2 returns a modules_invitation changeset", %{
      user: user,
      module: module
    } do
      assert %Ecto.Changeset{} =
               Modules.change_modules_invitations(
                 %ModulesInvitations{module_id: module.id, email: user.email},
                 %{module_id: module.id, user_id: user.id}
               )
    end

    test "add_modules_invitations/2 adds a module_invitation", %{user: user, module: module} do
      assert {:ok, _} =
               Modules.add_modules_invitations(%{module_id: module.id, email: user.email})
    end

    test "check_and_add_new_user_modules_invitations/1 adds new user to module", %{
      module: module,
      university: university
    } do
      email = unique_user_email()
      Modules.add_modules_invitations(%{module_id: module.id, email: email})

      user =
        user_fixture(%{email: email, university: university.id}) |> Handin.Repo.preload(:modules)

      assert user.modules == []

      Modules.check_and_add_new_user_modules_invitations(%{user: user})

      assert user.modules == [module]
    end
  end

  describe "get_assignments_count/2" do
    test "returns all the number of assignments for lecturer", %{module: module} do
      assignment_fixture(%{module_id: module.id})
      assignment_fixture(%{module_id: module.id})

      assert Modules.get_assignments_count(module.id, "lecturer") == 2
    end

    test "returns only started assignments count for students", %{module: module} do
      now = DateTime.utc_now() |> DateTime.shift_zone!("Europe/Dublin")

      assignment_fixture(%{
        module_id: module.id,
        start_date: DateTime.add(now, -1, :day),
        due_date: DateTime.add(now, 1, :day)
      })

      assignment_fixture(%{
        module_id: module.id,
        start_date: DateTime.add(now, 1, :day),
        due_date: DateTime.add(now, 2, :day)
      })

      assert Modules.get_assignments_count(module.id, "student") == 1

      assignment_fixture(%{
        module_id: module.id,
        start_date: DateTime.add(now, -1, :day),
        due_date: DateTime.add(now, 1, :day)
      })

      assert Modules.get_assignments_count(module.id, "student") == 2
    end
  end

  describe "assignment_exists?/2" do
    test "returns true if assignment exists", %{module: module} do
      assignment = assignment_fixture(%{module_id: module.id})

      assert Modules.assignment_exists?(module.id, assignment.id) == true
    end

    test "returns false if assignment does not exist", %{module: module} do
      assert Modules.assignment_exists?(module.id, "non existent assignment id") == false
    end
  end

  describe "list_assignments_for/2" do
    test "returns all the assignments for the module for lecturer", %{module: module} do
      assignments =
        [
          assignment_fixture(%{module_id: module.id}),
          assignment_fixture(%{module_id: module.id}),
          assignment_fixture(%{module_id: module.id})
        ]

      assert Modules.list_assignments_for(module.id, "lecturer") == assignments
    end

    test "returns only started assignments for students", %{module: module} do
      now = DateTime.utc_now() |> DateTime.shift_zone!("Europe/Dublin")

      assignment =
        assignment_fixture(%{
          module_id: module.id,
          start_date: DateTime.add(now, -1, :day),
          due_date: DateTime.add(now, 1, :day)
        })

      assignment_fixture(%{
        module_id: module.id,
        start_date: DateTime.add(now, 1, :day),
        due_date: DateTime.add(now, 2, :day)
      })

      assert Modules.list_assignments_for(module.id, "student") == [assignment]

      assignments = [
        assignment,
        assignment_fixture(%{
          module_id: module.id,
          start_date: DateTime.add(now, -1, :day),
          due_date: DateTime.add(now, 1, :day)
        })
      ]

      assert Modules.list_assignments_for(module.id, "student") == assignments
    end
  end
end
