defmodule Handin.Worker.BulkStudentRegistrationWorker do
  use Oban.Worker

  alias Handin.Modules.AddUserToModuleParams
  alias Handin.Modules
  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, module} = Handin.Modules.get_module(args["module_id"])

    user =
      args["user"]
      |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)

    Modules.add_users_to_module(%AddUserToModuleParams{module: module, users: [user]})
  end
end
