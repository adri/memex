defmodule MemexWeb.PageLive do
  use MemexWeb, :surface_live_view

  alias Memex.Search.Query
  alias Memex.Search.Sidebars
  alias MemexWeb.Timeline
  alias MemexWeb.SearchResultStats
  alias MemexWeb.SearchBar
  alias MemexWeb.DatesFacet
  alias MemexWeb.CloseCircles
  alias MemexWeb.SidebarsComponent
  alias MemexWeb.Components.Icons.SettingsIcon
  alias MemexWeb.Components.Badge

  data query, :string, default: ""
  data items, :list, default: []
  data page, :number, default: 1
  data dates, :list, default: []
  data total_hits, :number, default: 0
  data sidebars, :list, default: Sidebars.init()

  @impl true
  def render(assigns) do
    ~F"""
    <div class="mx-auto mt-3">
      <SearchBar query={@query} />
      <div :if={@query == ""}>
        <CloseCircles />
      </div>
      <div :if={@query != ""} class="flex items-start">
        <div class="w-4/5 mt-8">
          <SearchResultStats total_hits={@total_hits} />
          <Timeline query={@query} items={@items} page={@page} class="ml-12 md:ml-20" enable_load_more />
        </div>
        <div class="w-1/5 overflow-hidden pl-5 text-white">
          <DatesFacet dates={@dates} />
        </div>
        <SidebarsComponent sidebars={@sidebars} socket={assigns.socket} />
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, socket |> assign(query: "", page: 1, items: [])}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(query: query, page: 1) |> search()}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> search()}
  end

  def handle_event("filter-date", data, %{assigns: %{query: string}} = socket) do
    query =
      Query.from_string(string)
      |> Query.add_filter(data["key"], data["value"])
      |> Query.to_string()

    {:noreply, socket |> assign(query: query, page: 1) |> search()}
  end

  @impl true
  def handle_event("open-sidebar", data, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, socket |> assign(sidebars: Sidebars.open(sidebars, data))}
  end

  @impl true
  def handle_event("close-last-sidebar", _key, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, socket |> assign(sidebars: Sidebars.close_last(sidebars))}
  end

  defp search(%{assigns: %{page: page, query: string}} = socket) do
    query = Query.from_string(string)

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
end
