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

  def catalogues do
    [
      # Local catalogue
      "priv/catalogue",
      # Dependencies catalogues
      "deps/surface/priv/catalogue",
      "deps/surface_bulma/priv/catalogue",
      # External catalogues
      Path.expand("../my_componensts/priv/catalogue"),
      "/Users/johndoe/workspace/other_componensts/priv/catalogue"
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:con_cache, "~> 0.13"},
      {:earmark, "~> 1.4.16"},
      {:cloak_ecto, "~> 1.2.0"},
      {:ecto_sql, "~> 3.4"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:ex_check, "~> 0.13.0", only: [:dev], runtime: false},
      {:exqlite, "~> 0.11.3"},
      {:finch, "~> 0.8.2"},
      {:floki, ">= 0.27.0", only: :test},
      {:gettext, "~> 0.11"},
      {:git_diff, "~> 0.6.2"},
      {:hackney, "~> 1.16.0"},
      {:jason, "~> 1.0"},
      {:money, "~> 1.9"},
      {:month, "~> 2.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.18.0"},
      {:phoenix, "~> 1.6.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.15.9"},
      {:surface, "~> 0.9.0"},
      {:surface_catalogue, "~> 0.5.0"},
      {:surface_formatter, "~> 0.7.5", only: :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:tesla, "~> 1.4.0"},
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
      setup: ["deps.get", "cmd npm install --prefix assets"],
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
