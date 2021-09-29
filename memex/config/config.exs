# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :memex, MemexWeb.Endpoint,
  url: [host: "localhost"],
  http: [ip: {0, 0, 0, 0}],
  secret_key_base: "BP29B2R/vGyAzIXMvxN0W8Qs/Ok1UjxP7/mDqoAL872Ima1bZMKhZ09ZYQqlTn96",
  render_errors: [view: MemexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Memex.PubSub,
  live_view: [signing_salt: "lj/89OzE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :memex, ecto_repos: [Memex.Repo]

config :memex, Memex.Repo,
  url: System.get_env("POSTGRES_DSN"),
  pool_size: 5,
  timeout: 60_000

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --splitting --format=esm --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# config :tesla, adapter: Tesla.Adapter.Hackney
config :tesla, :adapter, {Tesla.Adapter.Finch, name: MyFinch}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
