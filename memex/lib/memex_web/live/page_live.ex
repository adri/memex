defmodule MemexWeb.PageLive do
  use MemexWeb, :live_view

  alias Memex.Search.Query
  alias Memex.Search.Sidebars
  alias Memex.Search.Meilisearch

  @default_assigns [
    results: %{},
    dates: %{},
    metadata: nil,
    suggestion: nil,
    surroundings: nil,
    search_ref: nil
  ]
  @highlight_regex ~r/<em>.*<\/em>(\w*)\W/u

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        sidebars: Sidebars.init(),
        query: "",
        page: 1,
        suggestion: nil,
        surroundings: nil,
        search_ref: nil
      )

    {:ok, socket, temporary_assigns: [results: %{}, dates: %{}, metadata: nil]}
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
  def handle_event("filter-date", %{"date" => date}, %{assigns: %{query: string}} = socket) do
    query =
      Query.from_string(string)
      |> Query.add_filter("date_month", date)

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
        %{assigns: %{query: query, suggestion: suggestion}} = socket
      )
      when not is_nil(suggestion) do
    {:noreply,
     socket
     |> assign(query: query <> suggestion, suggestion: nil, page: 1)
     |> search()
     |> push_event("force-input-value", %{value: query <> suggestion})}
  end

  @impl true
  def handle_event("accept-suggestion", _key, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("open-sidebar", data, %{assigns: %{sidebars: sidebars}} = socket) do
    {:ok, data} = Meilisearch.find(data["id"])
    data |> IO.inspect(label: "72")

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
          result = Memex.Search.Meilisearch.search(query, page, surroundings)
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
  end
end
