defmodule Memex.Search.Meilisearch do
  alias Memex.Search.Query

  def search(query = %Query{}, page, client \\ new()) do
    params = query_to_params(query, page)
    index_name = System.get_env("INDEX_NAME")

    client
    |> Tesla.post("/indexes/#{index_name}/search", params)
    |> case do
      {:ok, %{status: 200} = response} -> {:ok, response.body}
      _ -> {:error, %{}}
    end
  end

  defp query_to_params(query, page) do
    params =
      %{
        "q" => query.query,
        "limit" => 20,
        "offset" => (page - 1) * 20,
        "facetsDistribution" => ["date_month"],
        "attributesToHighlight" => ["*"]
      }
      |> add_filters_to_params(query.filters)
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
