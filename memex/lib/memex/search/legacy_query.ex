defmodule Memex.Search.LegacyQuery do
  @moduledoc """
  Options for select:
  - `:hits_with_highlights`: Return hits with highlights (formatted as HTML)
  - `:total_hits`: Return total hits count
  - `facet: "month"`: Return facet counts for each month
  """
  defstruct select: :hits_with_highlights,
            query: "",
            filters: %{},
            page: 1,
            limit: nil,
            order_by: []

  def add_filter(query, key, value), do: put_in(query.filters[key], value)

  def remove_filter(query, key), do: elem(pop_in(query.filters[key]), 1)

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
    if String.contains?(value, " ") do
      "\"#{value}\""
    else
      value
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
    Enum.reduce(filters, %{}, fn [_, key, value], acc -> Map.put(acc, key, String.trim(value, "\"")) end)
  end
end
