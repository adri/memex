defmodule Memex.Search.Meilisearch do
  alias Memex.Search.Query

  @date_facet "date_month"
  @results_per_page 20

  def search(query = %Query{}, page, client \\ new()) do
    index_name = System.get_env("INDEX_NAME")
    {:ok, settings} = get_index_settings(index_name, client)
    params = query_to_params(query, page, settings)
    IO.inspect(params)

    client
    |> Tesla.post("/indexes/#{index_name}/search", params)
    |> case do
      {:ok, %{status: 200} = response} -> {:ok, response.body}
      _ -> {:error, %{}}
    end
  end

  defp query_to_params(query, page, settings) do
    params =
      %{
        "q" => query.query,
        "limit" => 20,
        "offset" => (page - 1) * 20,
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
      Tesla.Middleware.JSON
      #     , Tesla.Middleware.Logger
    ]

    # {Tesla.Middleware.Headers [{"authorization", "token xyz"}]}

    Tesla.client(middleware)
  end
end
