defmodule Memex.MixProject do
  use Mix.Project

  def project do
    [
      app: :memex,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:con_cache, "~> 0.13"},
      {:ex_check, "~> 0.13.0", only: [:dev], runtime: false},
      {:phoenix, "~> 1.5.7"},
      {:phoenix_live_view, "~> 0.15.7"},
      {:floki, ">= 0.27.0", only: :test},
      {:finch, "~> 0.5"},
      {:git_diff, "~> 0.6.2"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:tzdata, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, "~> 0.15.9"},
      {:gettext, "~> 0.11"},
      {:tesla, "~> 1.4.0"},
      {:surface, "~> 0.4.0"},
      {:money, "~> 1.4"},
      {:month, "~> 2.1"},
      {:hackney, "~> 1.16.0"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
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
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
