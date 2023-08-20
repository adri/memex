defmodule MemexWeb.PageLive do
  @moduledoc false
  use MemexWeb, :surface_live_view

  alias Memex.Search.LegacyQuery
  alias Memex.Search.Query
  alias Memex.Search.Sidebars
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
  data(sidebars, :list, default: Sidebars.init())

  def mount(params, _session, socket) do
    Sidebars.subscribe()

    {:ok, assign(socket, debug: Map.has_key?(params, "debug"))}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="mx-auto mt-3">
      <SearchBar query={@query} />
      <div :if={@query == ""}>
        <Badge class="absolute right-2 top-12" click="open-sidebar" values={type: "settings"}>
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
        <div :if={@query != ""} class="w-4/5 mt-8">
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
        <div :if={@query != ""} class="w-1/5 overflow-hidden pl-5 text-white">
          <DatesFacet dates={@dates} loading={false} />
        </div>
        <SidebarsComponent sidebars={@sidebars} socket={assigns.socket} />
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, assign(socket, query: "", filters: [], page: 1, selected_index: 0, items: [])}
  end

  def handle_event("search", %{"query" => query, "filters" => filters}, socket) do
    {:noreply, socket |> assign(query: query, filters: filters, selected_index: 0, page: 1) |> search()}
  end

  def handle_event("completion", %{"sources" => sources, "key" => key, "value" => value}, socket) do
    options =
      key
      |> Memex.Schema.Catalog.search(value, sources)
      |> Enum.map(fn %{"type" => type, "value" => value} ->
        %{
          "type" => type,
          "label" => value
        }
      end)

    {:reply, %{"options" => options}, socket}
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

  def handle_event("filter-date", data, %{assigns: %{query: string}} = socket) do
    query =
      string
      |> LegacyQuery.from_string()
      |> LegacyQuery.remove_filter("time")
      |> LegacyQuery.add_filter(data["key"], data["value"])
      |> LegacyQuery.to_string()

    {:noreply, socket |> assign(query: query, page: 1) |> search()}
  end

  def handle_event("filter-reset", data, socket) do
    query =
      ""
      |> LegacyQuery.from_string()
      |> LegacyQuery.add_filter(data["key"], data["value"])
      |> LegacyQuery.to_string()

    {:noreply, socket |> assign(query: query, page: 1) |> search()}
  end

  @impl true
  def handle_event("open-sidebar", data, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.open(sidebars, data))}
  end

  @impl true
  def handle_event("close-last-sidebar", _key, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.close_last(sidebars))}
  end

  defp search(%{assigns: %{page: page, filters: filters}} = socket) do
    query = Query.from_filters(filters)

    socket
    |> async_query(:items, [], %{
      query
      | select: :hits_with_highlights,
        order_by: ["created_at_desc"],
        limit: 10 * page
    })
    |> async_query(:dates, [], %{query | select: [facet: "month"]})
    |> async_query(:total_hits, nil, %{query | select: :total_hits})
  end

  def handle_info(%{event: event, payload: payload}, socket) do
    handle_event(event, payload, socket)
  end
end
