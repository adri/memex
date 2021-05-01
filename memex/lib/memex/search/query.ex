defmodule Memex.Search.Query do
  defstruct query: "", filters: %{}, page: 1, highlights: [""]

  def add_filter(query, key, value), do: put_in(query.filters[key], value)

  def has_filters(query), do: query.filters !== %{}

  def disable_highlights(query), do: %{query | highlights: []}

  def to_string(query) do
    []
    |> Enum.concat([query.query])
    |> Enum.concat(Enum.map(query.filters, fn {key, value} -> "#{key}:#{value}" end))
    |> Enum.join(" ")
    |> String.trim()
  end

  def from_string(string) do
    filters = Regex.scan(~r/(\w+):(\S+)/, string)

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
      Map.put(acc, key, value)
    end)
  end
end
