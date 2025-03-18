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
        text={@assignment.name}
        href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/details"}
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
      <:item text="Settings" href={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/settings"} />
    </.tabs>

    <.simple_form for={@form} class="" phx-submit="save">
      <div class="w-1/2">
        <.input
          field={@form[:programming_language_id]}
          label="Language"
          type="select"
          prompt="Select Programming Language"
          options={@programming_languages}
        />
      </div>
      <div class="w-1/2">
        <.label for="Run Script">Run Script</.label>
        <div
          class=" p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400"
          role="alert"
        >
          <span class="font-medium">Info alert!</span>
          This is a bash script that will run before your tests. Use this to setup environment variables, install dependencies, and any other setup you need to do.
        </div>
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
      <.button
        class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
        phx-disable-with="Saving..."
      >
        Save
      </.button>
    </.simple_form>
    <.header class="mb-4 mt-10">Test Resource Files</.header>
    <div
      class=" w-1/2 p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400"
      role="alert"
    >
      <span class="font-medium">Info alert!</span>
      Test resource files are additional files that can be used during the testing of assignments. These files can include sample input data, configuration files, or any other resources needed to run the tests effectively.
    </div>
    <div class="w-1/2">
      <.link
        class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800 mb-4"
        patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/add_helper_files"}
      >
        Add
      </.link>
      <.table
        id="helper-files"
        rows={Enum.filter(@assignment.assignment_files, &(&1.file_type == :test_resource))}
      >
        <:col :let={assignment_file} label="name">{assignment_file.file.file_name}</:col>
        <:action :let={assignment_file}>
          <.link
            class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
            phx-click={JS.push("delete_file", value: %{assignment_file_id: assignment_file.id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    <.header class="mb-4 mt-10">Solution Files</.header>
    <div
      class=" w-1/2 p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400"
      role="alert"
    >
      <span class="font-medium">Info alert!</span>
      This is optional. You can add solution files to your assignment. These files will be used to see if your tests are working. Students wont have access to these files.
    </div>
    <div class="w-1/2">
      <.link
        class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800 mb-4"
        patch={~p"/modules/#{@module.id}/assignments/#{@assignment.id}/add_solution_files"}
      >
        Add
      </.link>
      <.table
        id="solution-files"
        rows={Enum.filter(@assignment.assignment_files, &(&1.file_type == :solution))}
      >
        <:col :let={assignment_file} label="name">{assignment_file.file.file_name}</:col>
        <:action :let={assignment_file}>
          <.link
            class="focus:outline-none text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-4 py-2 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900"
            phx-click={JS.push("delete_file", value: %{assignment_file_id: assignment_file.id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
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
    user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, user),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module.id) do
      {:ok,
       socket
       |> assign(current_page: :modules)
       |> assign(:module, module)
       |> assign(:assignment, assignment)
       |> assign(:module_user, module_user)
       |> assign(:page_title, "#{module.name} - #{assignment.name}")
       |> assign(:run_script, assignment.run_script)
       |> assign(
         :programming_languages,
         ProgrammingLanguages.list_programming_languages() |> Enum.map(&{&1.name, &1.id})
       )
       |> LiveMonacoEditor.set_value(assignment.name)
       |> assign_form(Assignments.change_assignment(assignment))}
    else
      {:error, reason} ->
        {:ok,
         push_navigate(socket, to: ~p"/modules/#{id}/assignments")
         |> put_flash(:error, reason)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :add_helper_files, _) do
    socket
    |> assign(:page_title, "Add Test Resources")
  end

  defp apply_action(socket, :add_solution_files, _) do
    socket
    |> assign(:page_title, "Add Solution Files")
  end

  defp apply_action(socket, _, _) do
    socket
  end

  @impl true
  def handle_event(
        "save",
        %{
          "assignment" => %{"programming_language_id" => programming_language_id}
        },
        socket
      ) do
    {:ok, assignment} =
      Assignments.update_assignment(socket.assigns.assignment, %{
        "programming_language_id" => programming_language_id,
        "run_script" => socket.assigns.run_script
      })

    {:noreply,
     socket
     |> assign(:assignment, assignment)
     |> put_flash(:info, "Environment updated successfully")
     |> assign_form(Assignments.change_assignment(assignment))}
  end

  def handle_event("code-editor-lost-focus", %{"value" => value}, socket) do
    {:noreply,
     socket
     |> assign(:run_script, value)
     |> assign_form(
       Assignments.change_assignment(socket.assigns.assignment, %{"run_script" => value})
     )}
  end

  def handle_event("delete_file", %{"assignment_file_id" => id}, socket) do
    assignment_id = socket.assigns.assignment.id
    module_id = socket.assigns.module.id

    with {:ok, assignment_file} <- Assignments.get_assignment_file(id),
         {:ok, _} <- Assignments.delete_assignment_file(assignment_file),
         {:ok, assignment} <- Assignments.get_assignment(assignment_id, module_id) do
      {:noreply,
       socket
       |> put_flash(:info, "File deleted successfully")
       |> assign(:assignment, assignment)}
    else
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
  end

  @impl true
  def handle_info({HandinWeb.AssignmentLive.FileUploadComponent, {:saved, assignment}}, socket) do
    {:noreply, assign(socket, :assignment, Assignments.get_assignment!(assignment.id))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
