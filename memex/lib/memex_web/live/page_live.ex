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

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        sidebars: Sidebars.init(),
        query: "",
        items: [],
        dates: [],
        total_hits: nil,
        page: 1
      )

    # todo: maybe move some data in temporary_assigns again,
    # if change tracking is fixed in surface (using component functions)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = Map.get(params, "query", "")

    cond do
      query == "" ->
        {:noreply, socket}

      query == socket.assigns.query ->
        {:noreply, socket}

      true ->
        handle_event("search", %{"query" => query}, socket)
    end
  end

  @impl true
  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, socket |> assign(query: "", page: 1, items: [])}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(query: query, page: 1) |> search()}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> search()}
  end

  @impl true
  def handle_event(
        "filter-date",
        %{"key" => key, "value" => value},
        %{assigns: %{query: string}} = socket
      ) do
    query =
      Query.from_string(string)
      |> Query.add_filter(key, value)
      |> Query.to_string()

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

    # todo: decide to keep updating the URL or not
    # |> push_patch(to: Routes.page_path(socket, :index, query: string))
  end
end
