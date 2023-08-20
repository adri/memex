defmodule Memex.Schema.Catalog do
  @moduledoc false
  alias Memex.Importer

  def search(key, value, sources) do
    Enum.reduce(sources, [], fn context, acc -> acc ++ search_source(context, key, value) end)
  end

  defp search_source("field_keys", _key, _value) do
    Importer.available_importers()
    |> Map.values()
    |> Enum.reduce([], fn module, acc ->
      acc ++ module.__schema__(:fields)
    end)
    |> Enum.map(fn field -> %{"type" => "field_keys", "value" => field} end)
  end

  defp search_source(_context, _key, _value), do: []
end
