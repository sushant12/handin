defmodule HandinWeb.Admin.UserListLive.Index do
  use HandinWeb, :live_view
  alias Handin.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Flop.Phoenix.table
      opts={HandinWeb.FlopConfig.table_opts()}
      items={@streams.users}
      meta={@meta}
      path={~p"/admin/users"}
    >
      <:col :let={{_id, user}} label="">
        <%= user.index %>
      </:col>
      <:col :let={{_id, user}} field={:email} label="Email">
        <%= user.email %>
      </:col>
      <:col :let={{_id, user}} field={:role} label="Role">
        <%= user.role %>
      </:col>
      <:action :let={{id, user}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          patch={~p"/admin/users/#{user.id}/edit"}
        >
          Edit
        </.link>
        <.link
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </Flop.Phoenix.table>

    <div class="flex justify-center">
      <Flop.Phoenix.pagination
        opts={HandinWeb.FlopConfig.pagination_opts()}
        meta={@meta}
        path={~p"/admin/users"}
      />
    </div>

    <.modal
      :if={@live_action == :edit}
      id="user-edit-modal"
      show
      on_cancel={JS.patch(~p"/admin/users")}
    >
      <.live_component
        module={HandinWeb.Admin.UserListLive.Edit}
        id={:edit}
        action={@live_action}
        user={@user}
        patch={~p"/admin/users"}
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

  defp apply_action(socket, :edit, %{"user_id" => user_id}) do
    socket
    |> assign(:user, Accounts.get_user!(user_id))
    |> assign(:page_title, "Edit User")
  end

  defp apply_action(socket, _, params) do
    %{users: users, meta: meta} = Accounts.list_users(params)

    users = users |> Enum.with_index(1) |> Enum.map(fn {u, i} -> Map.put(u, :index, i) end)

    socket
    |> stream(:users, users, reset: true)
    |> assign(:current_page, :users)
    |> assign(:meta, meta)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    Accounts.delete_user(user)
    {:noreply, socket |> stream_delete(:users, user)}
  end

  @impl true
  def handle_info({HandinWeb.Admin.UserListLive.Edit, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end
end
