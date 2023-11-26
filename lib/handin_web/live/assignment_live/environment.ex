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
      <.simple_form for={@form} id="environment-setup-form">
        <.input
          field={@form[:programming_language_id]}
          label="Language"
          type="select"
          prompt="Select Programming Language"
          options={@programming_languages}
        />

        <LiveMonacoEditor.code_editor
          style="min-height: 450px; width: 100%;"
          opts={
            Map.merge(
              LiveMonacoEditor.default_opts(),
              %{"language" => "shell"}
            )
          }
        />
      </.simple_form>
      <div id="helper-files-container">
        <%!-- use table component here to display helper files --%>
      </div>
      <div id="support-files-container">
        <%!-- use table component here to display helper files --%>
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
