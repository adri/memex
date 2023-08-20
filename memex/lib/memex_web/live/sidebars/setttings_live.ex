defmodule MemexWeb.Sidebars.SettingsLive do
  @moduledoc false
  use MemexWeb, :surface_live_view

  alias Memex.Importer
  alias Memex.Schema.ImporterLog
  alias Memex.Search.LegacyQuery, as: Query
  alias Memex.Search.Sidebars
  alias MemexWeb.Components.Badge
  alias MemexWeb.Components.Icon
  alias MemexWeb.Components.Text
  alias MemexWeb.Timeline.Card

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Importer.subscribe()
    end

    {:ok, fetch_data(socket)}
  end

  def fetch_data(socket) do
    importers = Importer.configured_importers()

    socket =
      Enum.reduce(importers, socket, fn importer, socket ->
        query = Query.from_string("provider:#{importer.provider}")

        async_query(socket, "total_hits_#{importer.id}", nil, %{query | select: :total_hits})
      end)

    assign(socket, importers: importers, logs: ImporterLog.last_imports())
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <Text.H1>Settings</Text.H1>
      <Text.SubtTitle>Configure integrations and other settings.</Text.SubtTitle>

      <Text.H2>Importers</Text.H2>
      <Badge class="text-white bg-gray-900 float-right" click="open-sidebar" values={type: "settings"}>
        <:icon><Icon.Plus /></:icon>
        Add new
      </Badge>
      <Text.SubtTitle>Configure importers and what can be searched for.</Text.SubtTitle>

      <Card :for={importer <- @importers}>
        <:content>
          {importer.display_name}
          <p :if={@logs[importer.id]} class="text-xs dark:text-gray-500">{state_to_emoij(@logs[importer.id]["state"])} Last import at {@logs[importer.id]["inserted_at"]}, took {Postgrex.Interval.to_string(@logs[importer.id]["duration"])}
            <code :if={@logs[importer.id]["log"] != "[]"} class="text-xs dark:text-gray-500">{@logs[importer.id]["log"]}</code>
            <!-- imported document counts or barchards per week? -->
            <!-- average duration -->
            <!-- errors -->
            <!-- view documents [open another sidebar] -->
          </p>
        </:content>
        <:right>
          <button :if={assigns["total_hits_#{importer.id}"]}>
            {MemexWeb.TimelineView.number_short(assigns["total_hits_#{importer.id}"])} docs
          </button>
          <Badge click="import" values={id: importer.id}>
            <:icon><Icon.Plus /></:icon>
            Import
          </Badge>
        </:right>
      </Card>
    </div>
    """
  end

  defp state_to_emoij(state) do
    case state do
      "success" -> "✅"
      "error" -> "❌"
      "running" -> "⏳"
      _ -> "❓"
    end
  end

  @impl true
  def handle_event("open-sidebar", sidebar, socket) do
    Sidebars.broadcast_open(sidebar)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_importer", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("import", %{"id" => id}, socket) do
    config = Enum.find(socket.assigns.importers, &(&1.id == id))
    Importer.import(config)

    {:noreply, socket}
  end

  def handle_info({Importer, event}, socket) when not is_nil(event) do
    {:noreply, fetch_data(socket)}
  end

  def handle_info({Importer, _}, socket), do: {:noreply, socket}
end
