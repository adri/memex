defmodule Memex.Search.Meilisearch do
  alias Memex.Search.Query

  @date_facet "date_month"
  @results_per_page 20

  def search(query = %Query{}, page, surroundings, client \\ new()) do
    index_name = System.get_env("INDEX_NAME")
    {:ok, settings} = get_index_settings(index_name, client)
    params = query_to_params(query, page, settings)
    IO.inspect(params)

    client
    |> Tesla.post("/indexes/#{index_name}/search", params)
    |> maybe_load_surroundings(surroundings, index_name, client)
    |> case do
      {:ok, %{status: 200} = response} -> {:ok, response.body}
      _ -> {:error, %{}}
    end
  end

  defp maybe_load_surroundings(response, nil, _index_name, _client), do: response
  defp maybe_load_surroundings({:error, _} = response, [], _index_name, _client), do: response

  defp maybe_load_surroundings({:ok, %{status: 200} = response}, timestamp, index_name, client) do
    client
    |> Tesla.post("/indexes/#{index_name}/search", %{
      "q" => "",
      "filters" => "timestamp_unix > #{timestamp - 3600} AND timestamp_unix < #{timestamp + 600}",
      "limit" => 80,
      "attributesToHighlight" => ["*"]
    })
    |> case do
      {:ok, %{status: 200} = surrounding} ->
        {:ok,
         update_in(response.body["hits"], fn hits ->
           surrounding.body["hits"]
           |> Enum.into(%{}, fn hit -> {hit["id"], hit} end)
           |> Map.merge(Enum.into(hits, %{}, fn hit -> {hit["id"], hit} end))
           |> Map.values()
           |> Enum.sort_by(& &1["timestamp_unix"], :desc)
         end)}

      _ ->
        # Ignore errors because the original query worked
        {:ok, response}
    end
  end

  defp query_to_params(query, page, settings) do
    %{
      "q" => query.query,
      "limit" => @results_per_page * page,
      "facetsDistribution" => ["date_month"],
      "attributesToHighlight" => ["*"]
    }
    |> handle_filters(query.filters, settings)
  end

  defp handle_filters(params, filters, _settings) when filters == %{}, do: params

  defp handle_filters(params, all_filters, settings) do
    {facet_filters, filters} =
      Map.split(
        all_filters,
        Enum.reject(settings["attributesForFaceting"], fn x -> x == @date_facet end)
      )

    params
    |> add_filters_to_params(filters)
    |> add_facet_filters_to_params(facet_filters)
  end

  defp add_filters_to_params(params, filters) when filters == %{}, do: params

  defp add_filters_to_params(params, filters) do
    Map.merge(params, %{
      "filters" =>
        filters
        |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
        |> Enum.join(" AND ")
    })
  end

  defp add_facet_filters_to_params(params, facet_filters) when facet_filters == %{}, do: params

  defp add_facet_filters_to_params(params, facet_filters) do
    Map.merge(params, %{
      "facetFilters" =>
        facet_filters
        |> Enum.map(fn {key, value} -> "#{key}:#{value}" end)
    })
  end

  defp get_index_settings(index_name, client \\ new()) do
    ConCache.get_or_store(:search, "settings", fn ->
      client
      |> Tesla.get("/indexes/#{index_name}/settings")
      |> case do
        {:ok, %{status: 200} = response} -> {:ok, response.body}
        _ -> {:error, %{}}
      end
    end)
  end

  defp new() do
    url = System.get_env("MEILISEARCH_HOST")

    middleware = [
      {Tesla.Middleware.BaseUrl, url},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Telemetry
      # , Tesla.Middleware.Logger
    ]

    # {Tesla.Middleware.Headers [{"authorization", "token xyz"}]}

    Tesla.client(middleware)
  end
end
