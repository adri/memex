defmodule Memex.Search.Query do
  # :hits_with_highlights, :total_hits, facet: "month"
  defstruct select: :hits_with_highlights,
            query: "",
            filters: %{},
            page: 1,
            limit: nil,
            order_by: []

  def add_filter(query, key, value), do: put_in(query.filters[key], value)

  def add_sort(query, sort), do: pop_in(query.sort, sort)

  def select(query, select), do: put_in(query.select, select)

  def has_filters(query), do: query.filters !== %{}

  def to_string(query) do
    []
    |> Enum.concat([query.query])
    |> Enum.concat(Enum.map(query.filters, fn {key, value} -> "#{key}:#{maybe_quote(value)}" end))
    |> Enum.join(" ")
    |> String.trim()
  end

  defp maybe_quote(value) do
    case String.contains?(value, " ") do
      true -> "\"#{value}\""
      false -> value
    end
  end

  def from_string(string) do
    filters = Regex.scan(~r/(\w+):("[^"]*"|[^\s]+)/, string)

    %__MODULE__{
      query: parse_query(string, filters),
      filters: parse_filters(filters)
    }
  end

  defp parse_query(string, []), do: String.trim(string)

  defp parse_query(string, filters) do
    string
    |> String.replace(Enum.map(filters, fn [filter, _, _] -> filter end), "")
    |> String.trim()
  end

  defp parse_filters([]), do: %{}

  defp parse_filters(filters) do
    filters
    |> Enum.reduce(%{}, fn [_, key, value], acc ->
      Map.put(acc, key, String.trim(value, "\""))
    end)
  end
end
