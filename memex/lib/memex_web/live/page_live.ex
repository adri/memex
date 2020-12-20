defmodule MemexWeb.PageLive do
  use MemexWeb, :live_view

  alias Memex.Search.Query

  @default_assigns [results: %{}, dates: %{}, metadata: nil, suggestion: nil]
  @highlight_regex ~r/<em>.*<\/em>(\w*)\W/u

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, query: "", page: 1, suggestion: nil)
    {:ok, socket, temporary_assigns: [results: %{}, dates: %{}, metadata: nil]}
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
  def handle_event("filter-date", %{"date" => date}, %{assigns: %{query: string}} = socket) do
    query =
      Query.from_string(string)
      |> Query.add_filter("date_month", date)

    {:noreply, socket |> assign(query: Query.to_string(query), page: 1) |> search()}
  end

  @impl true
  def handle_event(
        "accept-suggestion",
        %{"key" => "ArrowRight"},
        %{assigns: %{query: query, suggestion: suggestion}} = socket
      ) do
    {:noreply,
     socket
     |> assign(query: query <> suggestion, suggestion: nil, page: 1)
     |> push_event("force-input-value", %{value: query <> suggestion})}
  end

  def handle_event("accept-suggestion", _key, socket) do
    {:noreply, socket}
  end

  defp search(%{assigns: %{page: page, query: string}} = socket) do
    query = Query.from_string(string)

    case Memex.Search.Meilisearch.search(query, page) do
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
          suggestion: get_suggestion(response["hits"])
        )

      _ ->
        socket
        |> assign(@default_assigns ++ [query: string, page: 1])
    end
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
