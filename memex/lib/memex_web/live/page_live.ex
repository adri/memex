defmodule MemexWeb.PageLive do
  @moduledoc false
  use MemexWeb, :surface_live_view

  alias Memex.Importer
  alias Memex.Search.Catalog
  alias Memex.Search.Chart, as: ChartQuery
  alias Memex.Search.Query
  alias Memex.Search.Sidebars
  alias MemexWeb.Chart
  alias MemexWeb.Components.Badge
  alias MemexWeb.Components.Icons.SettingsIcon
  alias MemexWeb.DatesFacet
  alias MemexWeb.SearchBar
  alias MemexWeb.SearchResultStats
  alias MemexWeb.SidebarsComponent
  alias MemexWeb.Timeline

  # todo: remove
  data(query, :string, default: "")
  data(filters, :list, default: [])
  data(items, :list, default: [])
  data(page, :number, default: 1)
  data(selected_index, :number, default: 0)
  data(dates, :list, default: [])
  data(total_hits, :number, default: 0)
  data(chart, :map, default: nil)
  data(sidebars, :list, default: Sidebars.init())

  def mount(params, _session, socket) do
    Sidebars.subscribe()

    socket =
      if connected?(socket) do
        Importer.subscribe()
        push_event(socket, "search:catalog", Catalog.snapshot())
      else
        socket
      end

    {:ok, assign(socket, debug: Map.has_key?(params, "debug"))}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="mx-auto mt-3">
      <SearchBar query={@query} />
      <div :if={@query == ""}>
        <Badge class="absolute right-2 top-6" click="open-sidebar" values={type: "settings"}>
          <:icon><SettingsIcon /></:icon>
        </Badge>
        <div class="flex items-start">
          <!-- <CloseCircles /> -->
          <!-- <Memex.Importers.Github.HomepageItem /> -->
          <div>
          </div>
        </div>
      </div>

      <div class="flex items-start">
        <div :if={@query != "" and @chart != nil} class="w-full mt-8 px-4">
          <Chart data={@chart} />
        </div>
        <div :if={@query != "" and @chart == nil} class="w-4/5 mt-8">
          <SearchResultStats total_hits={@total_hits} />
          <Timeline
            query={@query}
            items={@items}
            selected_index={@selected_index}
            page={@page}
            debug={@debug}
            class="ml-12 md:ml-20"
            enable_load_more
          />
        </div>
        <div :if={@query != "" and @chart == nil} class="w-1/5 overflow-hidden pl-5 text-white">
          <DatesFacet dates={@dates} loading={false} />
        </div>
        <SidebarsComponent sidebars={@sidebars} socket={assigns.socket} />
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply,
     assign(socket,
       query: "",
       filters: [],
       page: 1,
       selected_index: 0,
       items: [],
       chart: nil
     )}
  end

  def handle_event("search", %{"query" => query, "filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(query: query, filters: filters, selected_index: 0, page: 1)
     |> search()}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> search()}
  end

  def handle_event("key-pressed", %{"key" => "Enter"}, %{assigns: assigns} = socket) do
    selected_item = Enum.at(assigns.items, assigns.selected_index)

    cond do
      selected_item == nil && assigns.total_hits == 0 ->
        {:noreply, redirect(socket, external: "https://duckduckgo.com/?q=#{assigns.query}")}

      %{"website_url" => url} = selected_item ->
        {:reply, %{}, redirect(socket, external: url)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_event("key-pressed", %{"key" => "ArrowDown"}, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, selected_index: min(assigns.selected_index + 1, length(assigns.items)))}
  end

  def handle_event("key-pressed", %{"key" => "ArrowUp"}, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, selected_index: max(assigns.selected_index - 1, 0))}
  end

  def handle_event("key-pressed", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("open-sidebar", data, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.open(sidebars, data))}
  end

  @impl true
  def handle_event("close-last-sidebar", _key, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.close_last(sidebars))}
  end

  defp search(%{assigns: %{filters: filters}} = socket) do
    if ChartQuery.chart?(filters) do
      chart_search(socket)
    else
      timeline_search(socket)
    end
  end

  defp chart_search(%{assigns: %{filters: filters}} = socket) do
    chart_data = filters |> ChartQuery.build_spec() |> ChartQuery.query()
    assign(socket, chart: chart_data, items: [], dates: [], total_hits: 0)
  end

  defp timeline_search(%{assigns: %{page: page, filters: filters}} = socket) do
    query = Query.from_filters(filters)

    socket
    |> assign(chart: nil)
    |> async_query(:items, [], %{
      query
      | select: :hits_with_highlights,
        order_by: ["created_at_desc"],
        limit: 10 * page
    })
    |> async_query(:dates, [], %{Query.remove_filter(query, "month") | select: [facet: "month"]})
    |> async_query(:total_hits, nil, %{query | select: :total_hits})
  end

  def handle_info(%{event: event, payload: payload}, socket) do
    handle_event(event, payload, socket)
  end

  def handle_info({Importer, %Memex.Schema.ImporterLog{state: state}}, socket)
      when state in ["success", "error"] do
    Catalog.invalidate()
    {:noreply, push_event(socket, "search:catalog", Catalog.snapshot())}
  end

  def handle_info({Importer, _}, socket), do: {:noreply, socket}
end
