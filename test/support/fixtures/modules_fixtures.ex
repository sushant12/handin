defmodule Handin.ModulesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Handin.Modules` context.
  """
  def valid_module_name, do: "Module #{Enum.random(1..99)}"

  def valid_module_code, do: "CS#{Enum.random(100..999)}"

  @doc """
  Generate a module.
  """
  def module_fixture(attrs \\ %{}) do
    {:ok, module} =
      attrs
      |> Enum.into(%{
        name: valid_module_name(),
        code: valid_module_code()
      })
      |> Handin.Modules.create_module(attrs.user_id)

    module
  end
end
