defmodule HandinWeb.ModuleControllerTest do
  use HandinWeb.ConnCase, async: true
  import HandinWeb.Factory
  import Handin.AccountsFixtures

  alias Handin.Modules.Module

  setup do
    %{
      user: user_fixture(),
      lecturer: insert(:lecturer),
      module: insert(:module),
      module_struct: build(:module)
    }
  end

end
