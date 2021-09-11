defmodule MemexWeb.PageLive do
  use MemexWeb, :surface_live_view

  alias Memex.Search.Query
  alias Memex.Search.Sidebars
  alias Memex.Search.Postgres, as: Search
  alias MemexWeb.Timeline
  alias MemexWeb.SearchResultStats
  alias MemexWeb.SearchBar
  alias MemexWeb.DatesFacet
  alias MemexWeb.CloseCircles
  alias MemexWeb.SidebarsComponent

  @default_assigns [
    results: [],
    dates: %{},
    metadata: nil,
    suggestion: nil,
    surroundings: nil,
    search_ref: nil
  ]
  @highlight_regex ~r/<em>(.*)<\/em>/u

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
          <SearchResultStats totalHits={@metadata["totalHits"]} processingTimeMs={@metadata["processingTimeMs"]} />
          <Timeline query={@query} results={@results} page={@page} />
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
        results: [],
        page: 1,
        suggestion: nil,
        surroundings: nil,
        search_ref: nil
      )

    # maybe move results: [] in temporary_assigns again, if change tracking is fixed in surface (using component functions)
    {:ok, socket, temporary_assigns: [dates: %{}, metadata: nil]}
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
    {:noreply,
     socket
     |> assign(query: "", page: 1, surroundings: nil, suggestion: nil, results: [])}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply,
     socket |> assign(query: query, page: 1, surroundings: nil, suggestion: nil) |> search()}
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

    {:noreply,
     socket |> assign(query: Query.to_string(query), page: 1, surroundings: nil) |> search()}
  end

  @impl true
  def handle_event("show-surrounding", %{"timestamp" => timestamp}, socket) do
    {:noreply, socket |> assign(surroundings: String.to_integer(timestamp)) |> search()}
  end

  @impl true
  def handle_event(
        "accept-suggestion",
        %{"key" => "ArrowRight"},
        %{assigns: %{suggestion: suggestion}} = socket
      )
      when not is_nil(suggestion) do
    {:noreply,
     socket
     |> assign(query: suggestion, suggestion: nil, page: 1)
     |> search()
     |> push_event("force-input-value", %{value: suggestion})}
  end

  @impl true
  def handle_event("accept-suggestion", _key, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("open-sidebar", data, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.open(sidebars, data))}
  end

  @impl true
  def handle_event("close-last-sidebar", _key, %{assigns: %{sidebars: sidebars}} = socket) do
    {:noreply, assign(socket, sidebars: Sidebars.close_last(sidebars))}
  end

  defp search(%{assigns: %{page: page, query: string, surroundings: surroundings}} = socket) do
    pid = self()

    socket
    |> cancel_current_search()
    |> assign(query: string)
    |> assign(
      search_ref:
        spawn(fn ->
          query = Query.from_string(string)
          result = Search.search(query, page, surroundings)
          send(pid, {:search_result, string, result})
        end)
    )
  end

  defp cancel_current_search(socket) do
    socket.assigns.search_ref && Process.exit(socket.assigns.search_ref, :kill)

    socket
  end

  @impl true
  def handle_info({:search_result, string, result}, socket) do
    socket =
      case result do
        {:ok, response} ->
          socket
          |> assign(
            query: string,
            results: response["hits"],
            metadata: %{
              "totalHits" => response["nbHits"],
              "processingTimeMs" => response["processingTimeMs"]
            },
            dates: response["facetsDistribution"]["date_month"],
            suggestion: get_suggestion(response["hits"]),
            search_ref: nil
          )
          |> push_patch(to: Routes.page_path(socket, :index, query: string))

        _ ->
          socket
          |> assign(@default_assigns ++ [query: string, page: 1])
      end

    {:noreply, socket}
  end

  defp get_suggestion(results) do
    with result when not is_nil(result) <- Enum.at(results, 0) do
      Enum.find_value(result["_formatted"], nil, fn {_key, value} ->
        with value when is_binary(value) <- value,
             [_, found] <- Regex.run(@highlight_regex, value) do
          found
        else
          _ -> false
        end
      end)
    end

    nil
  end
end
