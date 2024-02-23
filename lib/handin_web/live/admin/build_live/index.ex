defmodule HandinWeb.Admin.BuildLive.Index do
  use HandinWeb, :live_view
  alias Handin.Assignments

  @impl true
  def render(assigns) do
    ~H"""
    <Flop.Phoenix.table
      opts={HandinWeb.FlopConfig.table_opts()}
      items={@streams.builds}
      meta={@meta}
      path={~p"/admin/builds"}
    >
      <:col :let={{_id, build}} label="">
        <%= build.index %>
      </:col>
      <:col :let={{_id, build}} label="ID">
        <%= build.id %>
      </:col>
      <:col :let={{_id, build}} field={:machine_id} label="Machine ID">
        <%= build.machine_id %>
      </:col>
      <:col :let={{_id, build}} field={:status} label="Status">
        <%= build.status %>
      </:col>

      <:action :let={{id, build}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          patch={~p"/admin/builds/#{build.id}/edit"}
        >
          Edit
        </.link>
        <.link
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={JS.push("delete", value: %{id: build.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </Flop.Phoenix.table>

    <div class="flex justify-center mt-5">
      <Flop.Phoenix.pagination
        opts={HandinWeb.FlopConfig.pagination_opts()}
        meta={@meta}
        path={~p"/admin/builds"}
      />
    </div>

    <.modal
      :if={@live_action == :edit}
      id="build-edit-modal"
      show
      on_cancel={JS.patch(~p"/admin/builds")}
    >
      <.live_component
        module={HandinWeb.Admin.BuildLive.Edit}
        id={:edit}
        action={@live_action}
        build={@build}
        patch={~p"/admin/builds"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"build_id" => build_id}) do
    socket
    |> assign(:build, Assignments.get_build!(build_id))
    |> assign(:page_title, "Edit Build")
  end

  defp apply_action(socket, _, params) do
    %{builds: builds, meta: meta} = Assignments.list_builds(params)

    builds = builds |> Enum.with_index(1) |> Enum.map(fn {b, i} -> Map.put(b, :index, i) end)
    socket
    |> stream(:builds, builds, reset: true)
    |> assign(:current_page, :builds)
    |> assign(:meta, meta)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    build = Assignments.get_build!(id)
    Assignments.delete_build(build)
    {:noreply, socket |> stream_delete(:builds, build)}
  end

  @impl true
  def handle_info({HandinWeb.Admin.BuildLive.Edit, {:saved, build}}, socket) do
    {:noreply, stream_insert(socket, :builds, build)}
  end
end
