defmodule Memex.Search.Query do
  defstruct count: nil,
            query: "",
            filters: %{},
            page: 1,
            limit: 20,
            highlights: true,
            order_by: []

  def add_filter(query, key, value), do: put_in(query.filters[key], value)

  def add_sort(query, sort), do: pop_in(query.sort, sort)

  def has_filters(query), do: query.filters !== %{}

  def disable_highlights(query), do: %{query | highlights: false}

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
