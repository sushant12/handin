defmodule HandinWeb.Auth do
  use HandinWeb, :verified_routes
  alias Handin.Modules

  def on_mount(:admin, _params, _session, socket) do
    if admin?(socket.assigns.current_user) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def on_mount(
        :lecturer_or_ta,
        %{"assignment_id" => _assignment_id, "id" => id},
        _session,
        socket
      ) do
    current_user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, current_user) do
      if module_user.role in [:lecturer, :teaching_assistant] do
        {:cont, socket}
      else
        socket =
          socket
          |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
          |> Phoenix.LiveView.redirect(to: ~p"/")

        {:halt, socket}
      end
    end
  end

  def on_mount(
        :lecturer_or_ta,
        %{"id" => id},
        _session,
        socket
      ) do
    current_user = socket.assigns.current_user

    with {:ok, module} <- Modules.get_module(id),
         {:ok, module_user} <-
           Modules.module_user(module, current_user) do
      if module_user.role in [:lecturer, :teaching_assistant] do
        {:cont, socket}
      else
        socket =
          socket
          |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
          |> Phoenix.LiveView.redirect(to: ~p"/")

        {:halt, socket}
      end
    end
  end

  def on_mount(
        :lecturer_or_ta,
        _params,
        _session,
        socket
      ) do
    current_user = socket.assigns.current_user

    if current_user.role == :lecturer do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp admin?(user), do: user && user.role == :admin
end
