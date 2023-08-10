defmodule Handin.ModulesTest do
  use Handin.DataCase

  alias Handin.Modules
  alias Handin.Modules.Module

  @invalid_attrs %{name: nil, code: nil}

  describe "module" do
    setup do
      %{module: insert!(:module), lecturer: insert!(:lecturer)}
    end

    test "list_module/0 returns all module", %{module: module} do
      assert Modules.list_module() == [module]
    end

    test "get_module!/1 returns the module with given id", %{module: module} do
      assert Modules.get_module!(module.id) == Repo.preload(module, :assignments)
    end

    test "create_module/1 with valid data creates a module", %{module: module, lecturer: lecturer} do
      valid_attrs = %{"name" => "some name", "code" => "some code"}

      assert {:ok, %Module{} = module} = Modules.create_module(valid_attrs , lecturer.id)
      module = Repo.preload(module, :users)
      assert module.name == "some name"
      assert module.code == "some code"
      assert lecturer in  Map.get(module, :users)
    end

    test "create_module/1 with invalid data returns error changeset", %{module: module, lecturer: lecturer} do
      assert {:error, %Ecto.Changeset{}} = Modules.create_module(@invalid_attrs, lecturer.id)
    end

    test "update_module/2 with valid data updates the module", %{module: module} do
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Module{} = module} = Modules.update_module(module, update_attrs)
      assert module.name == "some updated name"
    end

    test "update_module/2 with invalid data returns error changeset", %{module: module} do
      assert {:error, %Ecto.Changeset{}} = Modules.update_module(module, @invalid_attrs)
      assert Repo.preload(module,:assignments) == Modules.get_module!(module.id)
    end

    test "delete_module/1 deletes the module", %{module: module} do
      assert {:ok, %Module{}} = Modules.delete_module(module)
      assert nil == Modules.get_module!(module.id)
    end

    test "change_module/1 returns a module changeset", %{module: module} do
      assert %Ecto.Changeset{} = Modules.change_module(module)
    end
  end
end
