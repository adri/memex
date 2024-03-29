defmodule Memex.MixProject do
  use Mix.Project

  def project do
    [
      app: :memex,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Memex.Application, []},
      extra_applications: [:logger, :con_cache, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bandit, "~> 1.0-pre"},
      {:con_cache, "~> 0.13"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.29"},
      {:cloak_ecto, "~> 1.2.0"},
      {:ecto_sql, "~> 3.10"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:ex_check, "~> 0.13.0", only: [:dev], runtime: false},
      {:exqlite, "~> 0.12.0"},
      {:file_system, "~> 0.2"},
      {:finch, "~> 0.16.0"},
      {:floki, ">= 0.27.0", only: :test},
      {:gettext, "~> 0.20"},
      {:git_diff, "~> 0.6.2"},
      {:hackney, "~> 1.16.0"},
      {:heroicons, "~> 0.5.3"},
      {:jason, "~> 1.0"},
      {:money, "~> 1.9"},
      {:month, "~> 2.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.19.3"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix, "~> 1.7.5"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.17.1"},
      {:surface, "~> 0.10"},
      {:surface_formatter, "~> 0.7.5", only: :dev},
      {:styler, "~> 0.7", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0.0"},
      {:tesla, "~> 1.7.0"},
      {:tzdata, "~> 1.0"}
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
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
