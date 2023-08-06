defmodule HandinWeb.Admin.ProgrammingLanguageLive.Index do
  use HandinWeb, :live_view

  alias Handin.ProgrammingLanguages
  alias Handin.ProgrammingLanguages.ProgrammingLanguage

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :programming_languages, ProgrammingLanguages.list_programming_languages())
     |> assign(:current_page, :programming_languages)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Programming language")
    |> assign(:programming_language, ProgrammingLanguages.get_programming_language!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Programming language")
    |> assign(:programming_language, %ProgrammingLanguage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Programming languages")
    |> assign(:programming_language, nil)
  end

  @impl true
  def handle_info(
        {HandinWeb.Admin.ProgrammingLanguageLive.FormComponent, {:saved, programming_language}},
        socket
      ) do
    {:noreply, stream_insert(socket, :programming_languages, programming_language)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    programming_language = ProgrammingLanguages.get_programming_language!(id)
    {:ok, _} = ProgrammingLanguages.delete_programming_language(programming_language)

    {:noreply, stream_delete(socket, :programming_languages, programming_language)}
  end
end
