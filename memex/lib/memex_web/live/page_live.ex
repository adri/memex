defmodule MemexWeb.PageLive do
  use MemexWeb, :live_view

  alias Memex.Search.Query

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, query: "", page: 1)
    {:ok, socket, temporary_assigns: [results: %{}, dates: %{}]}
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
    query = Query.from_string(string)
    |> Query.add_filter("date_month", date)
    {:noreply, socket |> assign(query: Query.to_string(query), page: 1) |> search()}
  end

  defp search(%{assigns: %{page: page, query: string}} = socket) do
    query = Query.from_string(string)

    case Memex.Search.Meilisearch.search(query, page) do
      {:ok, response} ->
        socket
        |> assign(
          query: string,
          results: response["hits"],
          dates: response["facetsDistribution"]["date_month"]
        )

      _ ->
        socket
        |> assign(query: string, page: 1, results: %{}, dates: %{})
    end
  end
end
