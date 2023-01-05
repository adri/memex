defmodule Memex.Importers.FishShell do
  alias Memex.Importer

  use Ecto.Schema
  @primary_key false
  schema "document" do
    field :provider, :string
    field :verb, :string
    field :id, :string
    field :date_month, :string
    field :timestamp_utc, :string
    field :timestamp_unix, :integer
    field :command, :string
  end

  def provider(), do: "terminal"

  def default_config() do
    %{
      schedule: :watcher
    }
  end

  def fetch(_config) do
    %Importer.Command{
      command: "fish",
      arguments: ["--command=history --show-time='<-SNIP->%s-;-%F %T-;-%Y-%m-;-'"]
    }
  end

  def transform(result) do
    result
    |> String.split("<-SNIP->")
    |> Enum.map(&String.split(&1, "-;-"))
    |> Enum.filter(&(&1 != [""]))
    |> Enum.map(fn [timestamp_unix, timestamp_utc, date_month, command] ->
      %{
        id: "terminal-#{Base.encode16(:crypto.hash(:sha256, timestamp_unix <> command))}",
        verb: "commanded",
        provider: "terminal",
        timestamp_unix: timestamp_unix,
        timestamp_utc: timestamp_utc,
        date_month: date_month,
        command: String.trim(command)
      }
    end)
  end

  defmodule TimeLineItem do
    use Surface.Component

    alias Phoenix.LiveView.JS

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <pre phx-click={open()} class="text-sm overflow-scroll"><code>{raw(String.replace(String.trim(@item["_formatted"]["command"]), "\n", "<br />"))}</code></pre>
      """
    end

    def open() do
      JS.dispatch("memex:clipcopy")
    end
  end
end
