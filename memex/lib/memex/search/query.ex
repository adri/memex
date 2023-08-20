defmodule Memex.Search.Query do
  @moduledoc """
  Options for select:
  - `:hits_with_highlights`: Return hits with highlights (formatted as HTML)
  - `:total_hits`: Return total hits count
  - `facet: "month"`: Return facet counts for each month
  """
  defstruct select: :hits_with_highlights,
            filters: [],
            page: 1,
            limit: nil,
            order_by: []

  # def add_filter(query, type, key, value), do: put_in(query.filters[key], value)
  # def remove_filter(query, key), do: elem(pop_in(query.filters[key]), 1)

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

  def from_filters(filters) do
    %__MODULE__{
      filters: filters
    }
  end
end
