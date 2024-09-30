defmodule Handin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    maybe_install_ecto_dev_logger()
    Logger.add_backend(Sentry.LoggerBackend)

    children = [
      # Start the Telemetry supervisor
      HandinWeb.Telemetry,
      # Start the Ecto repository
      Handin.Repo,
      {Oban, Application.fetch_env!(:handin, Oban)},
      # Start the PubSub system
      {Phoenix.PubSub, name: Handin.PubSub},
      # Start Finch
      {Finch, name: Handin.Finch},
      # Start the Endpoint (http/https)
      HandinWeb.Endpoint,
      # Start a worker by calling: Handin.Worker.start_link(arg)
      Handin.BuildSupervisor
      # {Handin.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Handin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  if Code.ensure_loaded?(Ecto.DevLogger) do
    defp maybe_install_ecto_dev_logger,
      do: Ecto.DevLogger.install(Handin.Repo)
  else
    defp maybe_install_ecto_dev_logger, do: :ok
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HandinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
