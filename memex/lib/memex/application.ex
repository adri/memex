defmodule Memex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MemexWeb.Telemetry,
      {Finch, name: Memex.Finch},
      {ConCache, [name: :search, ttl_check_interval: false]},
      # Start the PubSub system
      {Phoenix.PubSub, name: Memex.PubSub},
      # Start the Endpoint (http/https)
      MemexWeb.Endpoint,
      Memex.Repo,
      # Start a worker by calling: Memex.Worker.start_link(arg)
      # {Memex.Worker, arg}
      Memex.Vault,
      Memex.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MemexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
