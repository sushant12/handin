defmodule Handin.ModulesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Modules` context.
  """

  @doc """
  Generate a module.
  """
  def module_fixture(attrs \\ %{}) do
    {:ok, module} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Handin.Modules.create_module()

    module
  end
end
