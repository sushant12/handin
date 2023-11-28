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
            phx-blur="save_language"
          />
        </div>
        <div>
          <.label for="Run Script">Run Script</.label>
          <LiveMonacoEditor.code_editor
            style="min-height: 450px; width: 100%;"
            value={@assignment.run_script}
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
          <:col :let={file} label="name"><%= file.file.file_name %></:col>
          <:action :let={file}>
            <.link
              class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
              phx-click={JS.push("delete-file", value: %{support_file_id: file.id})}
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
          <:col :let={file} label="name"><%= file.file.file_name %></:col>
          <:action :let={file}>
            <.link
              class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
              phx-click={JS.push("delete-file", value: %{solution_file_id: file.id})}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
      </div>
    </div>
    <.modal
      :if={@live_action in [:add_helper_files, :add_solution_files]}
      id="assignment_files-modal"
      show
      on_cancel={JS.patch(~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment")}
    >
      <.live_component
        module={HandinWeb.AssignmentLive.FileUploadComponent}
        title={@page_title}
        id={@assignment.id}
        live_action={@live_action}
        assignment={@assignment}
        patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/environment"}
      />
    </.modal>
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

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :add_helper_files, _) do
    socket
    |> assign(:page_title, "Add Helper Files")
  end

  defp apply_action(socket, :add_solution_files, _) do
    socket
    |> assign(:page_title, "Add Solution Files")
  end

  defp apply_action(socket, _, _) do
    socket
  end

  @impl true
  def handle_event("save_language", %{"value" => programming_language_id}, socket) do
    {:ok, assignment} =
      Assignments.get_assignment!(socket.assigns.assignment.id)
      |> Assignments.update_assignment(%{"programming_language_id" => programming_language_id})

    {:noreply, socket |> assign(:assignment, assignment)}
  end

  def handle_event("code-editor-lost-focus", %{"value" => value}, socket) do
    {:ok, assignment} =
      Assignments.get_assignment!(socket.assigns.assignment.id)
      |> Assignments.update_assignment(%{"run_script" => value})

    {:noreply, socket |> assign(:assignment, assignment)}
  end

  def handle_event("delete-file", %{"support_file_id" => id}, socket) do
    id
    |> Assignments.get_support_file!()
    |> Assignments.delete_support_file()

    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)
    {:noreply, socket |> assign(:assignment, assignment)}
  end

  def handle_event("delete-file", %{"solution_file_id" => id}, socket) do
    id
    |> Assignments.get_solution_file!()
    |> Assignments.delete_solution_file()

    assignment = Assignments.get_assignment!(socket.assigns.assignment.id)
    {:noreply, socket |> assign(:assignment, assignment)}
  end

  @impl true
  def handle_info({HandinWeb.AssignmentLive.FileUploadComponent, {:saved, assignment}}, socket) do
    {:noreply, assign(socket, :assignment, Assignments.get_assignment!(assignment.id))}
  end
end
