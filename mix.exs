defmodule Handin.MixProject do
  use Mix.Project

  def project do
    [
      app: :handin,
      version: "0.1.0",
      elixir: "~> 1.17.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        list_unused_filters: true
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Handin.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.1.0"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6.2"},
      {:ecto_sql, "~> 3.12.0"},
      {:postgrex, ">= 0.19.1"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 0.20.17"},
      {:phoenix_live_dashboard, "~> 0.8.4"},
      {:swoosh, "~> 1.16.9"},
      {:finch, "~> 0.18"},
      {:telemetry_metrics, "~> 1.0.0"},
      {:telemetry_poller, "~> 1.1.0"},
      {:jason, "~> 1.4.3"},
      {:plug_cowboy, "~> 2.7.1"},
      {:nimble_csv, "~> 1.1"},
      {:waffle, "~> 1.1.9"},
      {:waffle_ecto, "~> 0.0.12"},
      {:ex_aws, "~> 2.5.4"},
      {:ex_aws_s3, "~> 2.5.3"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:gen_smtp, "~> 1.0"},
      {:live_monaco_editor, "~> 0.1.8"},
      {:timex, "~> 3.0"},
      {:sentry, "~> 10.7.0"},
      {:flop_phoenix, "~> 0.22.9"},
      {:torch, "~> 5.3"},
      {:oban, "~> 2.17"},
      {:ex_machina, "~> 2.8", only: :test},
      {:floki, ">= 0.36.2", only: :test},
      {:tailwind, "~> 0.2.3", runtime: Mix.env() == :dev},
      {:dialyxir, "~> 1.4.3", only: [:dev], runtime: false},
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.8.1", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "~> 1.5.3", only: :dev},
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:ecto_dev_logger, "~> 0.13", only: [:dev]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
