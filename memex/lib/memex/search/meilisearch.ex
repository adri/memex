defmodule Memex.Search.Meilisearch do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:7700"
  #  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
#    plug Tesla.Middleware.Logger
  plug Tesla.Middleware.JSON

  alias Memex.Search.Query

  def search(query = %Query{}, page) do
    params = query_to_params(query, page)
    IO.inspect(params, label: :search)

    post("/indexes/memex/search", params)
    |> case do
      {:ok, %{status: 200} = response} -> {:ok, response.body}
      _ -> {:error, %{}}
    end
  end

  defp query_to_params(query, page) do
    params = %{
      "q" => query.query,
      "limit" => 20,
      "offset" => (page - 1) * 20,
      "facetsDistribution" => ["date_month"],
      "attributesToHighlight" => ["*"]
    }

    if Query.has_filters(query) do
      Map.merge(params, %{
        "filters" => query.filters
         |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
         |> Enum.join(" AND ")
      })
    else
      params
    end
  end
end
