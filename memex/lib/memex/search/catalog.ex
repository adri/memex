defmodule Memex.Search.Catalog do
  @moduledoc """
  Builds the search-bar autocomplete catalog: every known filter key, its
  description, and (where applicable) the list of valid values.

  The catalog merges three sources:

    * **Global meta-keys** — `chart`, `x`, `y`, `from`, `range`, `provider`,
      `verb`, `month`. Defined in this module, with `chart_followup: true` on
      the keys that make sense after `chart:` (`x`, `y`, `from`, `range`).
    * **Per-importer field metadata** — each importer can opt in by exporting
      `field_metadata/0`, returning a map of `field => %{description, dynamic}`.
      Importers without it still contribute their bare field names (no
      description).
    * **Dynamic values** — for keys whose values come from the data
      (`provider`, `verb`, `month`, and any field flagged `dynamic: true`),
      `snapshot/0` runs distinct-value queries against `documents.body`.
  """

  import Ecto.Query

  alias Memex.Importer
  alias Memex.Repo
  alias Memex.Schema.Document

  # The catalog is shipped wholesale to the client; cap each per-field
  # dynamic list so pages with very high-cardinality fields (e.g. 2k+
  # distinct repo names) don't bloat the initial payload.
  @max_dynamic_values 200

  @global [
    %{
      key: "chart",
      name: "Chart",
      icon: "chart",
      description: "Display results as a chart",
      values: [
        %{value: "line", description: "Line chart over time"},
        %{value: "bar", description: "Bar chart"},
        %{value: "table", description: "Tabular view"}
      ]
    },
    %{
      key: "x",
      name: "X-axis",
      icon: "axis",
      description: "Chart x-axis bucket",
      chart_followup: true,
      values: [
        %{value: "day", description: "Group by day"},
        %{value: "week", description: "Group by week"},
        %{value: "month", description: "Group by month"}
      ]
    },
    %{
      key: "y",
      name: "Y-axis",
      icon: "axis",
      description: "Chart y-axis aggregation",
      chart_followup: true,
      values: [%{value: "count", description: "Count of documents"}]
    },
    %{
      key: "range",
      name: "Range",
      icon: "calendar",
      description: "Time range to look back",
      chart_followup: true,
      values: [
        %{value: "7d", description: "Last 7 days"},
        %{value: "30d", description: "Last 30 days"},
        %{value: "90d", description: "Last 90 days"},
        %{value: "6m", description: "Last 6 months"},
        %{value: "1y", description: "Last year"}
      ]
    },
    %{
      key: "provider",
      name: "Provider",
      icon: "source",
      description: "Document provider",
      chart_followup: true,
      dynamic: :providers_titlecase
    },
    %{
      key: "verb",
      name: "Action",
      icon: "verb",
      description: "Action type",
      dynamic: :verbs
    },
    %{
      key: "month",
      name: "Month",
      icon: "calendar",
      description: "Document month (YYYY-MM)",
      dynamic: :months
    }
  ]

  @doc """
  Returns the full catalog as a JSON-serialisable map. Shape:

      %{
        keys: [
          %{key: "chart", description: "...", chart_followup: false,
            values: [%{value: "line", description: "..."}, ...]},
          ...
        ]
      }
  """
  def snapshot do
    ConCache.get_or_store(:search, "catalog_snapshot", &compute_snapshot/0)
  end

  @doc "Bust the cached snapshot — call when documents change."
  def invalidate, do: ConCache.delete(:search, "catalog_snapshot")

  defp compute_snapshot do
    merged = (@global ++ importer_keys()) |> dedupe_by_key()
    dynamic = load_dynamic(merged)

    %{keys: Enum.map(merged, &materialise(&1, dynamic))}
  end

  defp dedupe_by_key(keys) do
    keys
    |> Enum.reduce({[], MapSet.new()}, fn entry, {acc, seen} ->
      if MapSet.member?(seen, entry.key) do
        {acc, seen}
      else
        {[entry | acc], MapSet.put(seen, entry.key)}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp materialise(entry, dynamic) do
    values =
      case entry do
        %{values: vs} -> vs
        %{dynamic: {:field, _} = src} -> Map.get(dynamic, src, [])
        %{dynamic: src} -> Map.get(dynamic, src, [])
        _ -> []
      end

    %{
      key: entry.key,
      name: Map.get(entry, :name) || humanize_key(entry.key),
      icon: Map.get(entry, :icon, "field"),
      description: Map.get(entry, :description, ""),
      chart_followup: Map.get(entry, :chart_followup, false),
      values: values
    }
  end

  defp humanize_key(key) do
    key
    |> String.replace("_", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp importer_keys do
    Importer.available_importers()
    |> Map.values()
    |> Enum.flat_map(&importer_entries/1)
  end

  defp importer_entries(module) do
    metadata =
      if function_exported?(module, :field_metadata, 0) do
        module.field_metadata()
      else
        %{}
      end

    # Importer fields without a description are intentionally excluded —
    # things like `id`, `timestamp_unix`, etc. would just be noise in the
    # autocomplete dropdown. Add metadata to surface them.
    Enum.flat_map(module.__schema__(:fields), fn field ->
      meta = Map.get(metadata, field)

      cond do
        global_key?(field) -> []
        is_nil(meta) -> []
        true ->
          [
            %{
              key: Atom.to_string(field),
              name: Map.get(meta, :name),
              icon: Map.get(meta, :icon, "field"),
              description: Map.get(meta, :description, ""),
              dynamic: Map.get(meta, :dynamic, false) && {:field, field}
            }
            |> Map.reject(fn {_k, v} -> v in [false, nil] end)
          ]
      end
    end)
  end

  @global_keys MapSet.new(Enum.map(@global, & &1.key))
  defp global_key?(field), do: MapSet.member?(@global_keys, Atom.to_string(field))

  defp load_dynamic(entries) do
    providers = distinct_values("provider")
    verbs = distinct_values("verb")
    months = distinct_values("date_month") |> Enum.sort(:desc) |> Enum.take(24)

    base = %{
      providers_titlecase: Enum.map(providers, &%{value: &1}),
      verbs: Enum.map(verbs, &%{value: &1}),
      months: Enum.map(months, &%{value: &1})
    }

    # Per-field dynamic lookups, only for importer keys flagged dynamic: true.
    Enum.reduce(entries, base, fn
      %{dynamic: {:field, field}}, acc ->
        values =
          field
          |> Atom.to_string()
          |> distinct_values()
          |> Enum.sort()
          |> Enum.take(@max_dynamic_values)
          |> Enum.map(&%{value: &1})

        Map.put(acc, {:field, field}, values)

      _, acc ->
        acc
    end)
  end

  defp distinct_values(field) do
    Repo.all(
      from(d in Document,
        select: fragment("distinct ? ->> ?", d.body, ^field),
        where: not is_nil(fragment("? ->> ?", d.body, ^field))
      )
    )
  end
end
