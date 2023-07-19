defmodule HandinWeb.ModulesLive do
  use HandinWeb, :live_view
  alias Handin.Modules

  def mount(_params, _session, socket) do
    modules = Modules.list_module()

    {:ok, assign(socket, modules: modules)}
  end

  def render(assigns) do
    ~H"""
    <div class="rounded-sm border border-stroke bg-white px-5 pt-6 pb-2.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:pb-1">
      <.modal id="add-module">
        <div class="fixed top-0 left-0 z-999999 flex h-full min-h-screen w-full items-center justify-center bg-black/90 px-4 py-5">
          <div class="w-full max-w-142.5 rounded-lg bg-white py-12 px-8 text-center dark:bg-boxdark md:py-15 md:px-17.5">
            <h3 class="pb-2 text-xl font-bold text-black dark:text-white sm:text-2xl">
              Module Details
            </h3>
            <span class="mx-auto mb-6 inline-block h-1 w-22.5 rounded bg-primary"></span>
            <.form :let={f} for={%{}} phx-submit="add-module">
              <div class="flex flex-col gap-5.5 p-6.5 ">
                <div class="text-left">
                  <label class="mb-6 font-medium text-xl text-black dark:text-white">
                    Name
                  </label>
                  <.input
                    field={f[:name]}
                    type="text"
                    class="w-full mb-4 rounded-lg border-[1.5px] border-stroke bg-transparent py-3 px-5 font-medium outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:focus:border-primary"
                    placeholder="Name for Module"
                    required
                  />
                  <label class="mb-6 font-medium text-xl text-black dark:text-white">
                    Code
                  </label>
                  <.input
                    field={f[:code]}
                    type="text"
                    class="w-full mb-4 rounded-lg border-[1.5px] border-stroke bg-transparent py-3 px-5 font-medium outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:focus:border-primary"
                    placeholder="Code for Module"
                    required
                  />
                </div>
              </div>
              <div class="-mx-3 flex flex-wrap gap-y-4">
                <div class="w-full px-3 2xsm:w-1/2">
                  <button class="block w-full rounded border border-stroke bg-gray p-3 text-center font-medium text-black transition hover:border-meta-1 hover:bg-meta-1 hover:text-white dark:border-strokedark dark:bg-meta-4 dark:text-white dark:hover:border-meta-1 dark:hover:bg-meta-1" phx-click={hide_modal("add-module")}>
                    Cancel
                  </button>
                </div>
                <div class="w-full px-3 2xsm:w-1/2">
                  <button type="submit" class="block w-full rounded border border-primary bg-primary p-3 text-center font-medium text-white transition hover:bg-opacity-90" phx-click={hide_modal("add-module")}>
                    Add Module
                  </button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      </.modal>
      <div class="flex flex-row justify-between">
        <h4 class="text-xl font-bold text-black dark:text-white">Modules</h4>
        <button class="rounded inline-flex items-center justify-center bg-primary py-2 px-10 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10" phx-click={show_modal("add-module")}>
          Add Module
        </button>
      </div>

      <div class="flex flex-col">
        <div class="grid grid-cols-4 rounded-sm bg-gray-2">
          <div class="p-2.5 xl:p-5">
            <h5 class="text-sm font-medium uppercase xsm:text-base">Name</h5>
          </div>
          <div class="p-2.5 text-center xl:p-5">
            <h5 class="text-sm font-medium uppercase xsm:text-base">Code</h5>
          </div>
          <div class="p-2.5 text-center xl:p-5 col-span-2">
            <h5 class="text-sm font-medium uppercase xsm:text-base">Options</h5>
          </div>
        </div>

        <div :for={module <- @modules} class="grid grid-cols-4 border-b border-stroke dark:border-strokedark">
          <div class="flex items-center gap-3 p-2.5 xl:p-5">
            <p class="hidden font-medium text-black dark:text-white sm:block">
              <%= module.name %>
            </p>
          </div>

          <div class="flex items-center justify-center p-2.5 xl:p-5">
            <p class="font-medium text-black dark:text-white"><%= module.code %></p>
          </div>

          <div class="hidden items-center justify-center p-2.5 sm:flex xl:p-5">
            <a href="#" class="w-full inline-flex items-center justify-center rounded-full bg-meta-3 py-3 px-10 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10">
              Edit
            </a>
          </div>
          <div class="hidden items-center justify-center p-2.5 sm:flex xl:p-5">
            <a href="#" class="w-full inline-flex items-center justify-center rounded-full bg-meta-3 py-3 px-10 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10">
              Delete
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("add-module", %{"name" => name, "code" => code} = _params, socket) do
    case Modules.create_module(%{name: name, code: code}) do
      {:ok, _module} ->
        modules = Modules.list_module()
        {:noreply, socket |> put_flash(:info, "Module created successfully." |> assign(modules: modules))}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create module.")}
    end
  end
end
