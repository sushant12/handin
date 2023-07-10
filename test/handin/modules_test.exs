defmodule Handin.ModulesTest do
  use Handin.DataCase

  alias Handin.Modules

  describe "module" do
    alias Handin.Modules.Module

    import Handin.ModulesFixtures

    @invalid_attrs %{name: nil}

    test "list_module/0 returns all module" do
      module = module_fixture()
      assert Modules.list_module() == [module]
    end

    test "get_module!/1 returns the module with given id" do
      module = module_fixture()
      assert Modules.get_module!(module.id) == module
    end

    test "create_module/1 with valid data creates a module" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Module{} = module} = Modules.create_module(valid_attrs)
      assert module.name == "some name"
    end

    test "create_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Modules.create_module(@invalid_attrs)
    end

    test "update_module/2 with valid data updates the module" do
      module = module_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Module{} = module} = Modules.update_module(module, update_attrs)
      assert module.name == "some updated name"
    end

    test "update_module/2 with invalid data returns error changeset" do
      module = module_fixture()
      assert {:error, %Ecto.Changeset{}} = Modules.update_module(module, @invalid_attrs)
      assert module == Modules.get_module!(module.id)
    end

    test "delete_module/1 deletes the module" do
      module = module_fixture()
      assert {:ok, %Module{}} = Modules.delete_module(module)
      assert_raise Ecto.NoResultsError, fn -> Modules.get_module!(module.id) end
    end

    test "change_module/1 returns a module changeset" do
      module = module_fixture()
      assert %Ecto.Changeset{} = Modules.change_module(module)
    end
  end
end
