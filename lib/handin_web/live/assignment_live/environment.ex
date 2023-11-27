defmodule HandinWeb.AssignmentLive.Environment do
  use HandinWeb, :live_view

  alias Handin.Modules
  alias Handin.Assignments
  alias Handin.ProgrammingLanguages
  @impl true
  def render(assigns) do
    ~H"""
    <.breadcrumbs>
      <:item text="Home" href={~p"/"} />
      <:item text="Modules" href={~p"/modules"} />
      <:item text={@module.name} href={~p"/modules/#{@module.id}/assignments"} />
      <:item
        text="Assignments"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}"}
        current={true}
      />
    </.breadcrumbs>

    <.tabs>
      <:item text="Details" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"} />
      <:item
        text="Environment"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
        current={true}
      />
      <:item text="Tests" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/tests"} />
      <:item
        text="Submissions"
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/submissions"}
      />
    </.tabs>

    <div>
      <.simple_form for={@form} id="environment-setup-form" class="mb-4">
        <div class="max-w-md mb-4">
          <.input
            field={@form[:programming_language_id]}
            label="Language"
            type="select"
            prompt="Select Programming Language"
            options={@programming_languages}
          />
        </div>
        <div>
          <.label for="Run Script">Run Script</.label>
          <LiveMonacoEditor.code_editor
            style="min-height: 450px; width: 100%;"
            opts={
              Map.merge(
                LiveMonacoEditor.default_opts(),
                %{"language" => "shell"}
              )
            }
          />
        </div>
      </.simple_form>

      <div id="helper-files-container" class="max-w-md mb-4">
        <.header class="mb-4">Helper Files</.header>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3"
          patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/add_helper_files"}
        >
          Add Helper Files
        </.link>
        <.table id="helper-files" rows={@assignment.support_files}>
          <:col :let={{_id, file}} label="name"><%= file.name %></:col>
          <:action :let={{id, file}}>
            <.link
              class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
              phx-click={JS.push("delete", value: %{id: file.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
      </div>
      <div id="solution-files-container " class="max-w-md mb-4">
        <.header class="mb-4">Solution Files</.header>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3"
          patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/add_solution_files"}
        >
          Add Solution Files
        </.link>
        <.table id="solution-files" rows={@assignment.solution_files}>
          <:col :let={{_id, file}} label="name"><%= file.name %></:col>
          <:action :let={{id, file}}>
            <.link
              class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
              phx-click={JS.push("delete", value: %{id: file.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id, "assignment_id" => assignment_id}, _session, socket) do
    assignment = Assignments.get_assignment!(assignment_id)
    module = Modules.get_module!(id)

    {:ok,
     socket
     |> assign(current_page: :modules)
     |> assign(:module, module)
     |> assign(:assignment, assignment)
     |> assign(:form, Assignments.change_assignment(assignment) |> to_form())
     |> assign(
       :programming_languages,
       ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})
     )
     |> LiveMonacoEditor.set_value(assignment.name)}
  end
end
