defmodule Memex.Search.CatalogTest do
  use ExUnit.Case, async: false

  alias Memex.Search.Catalog

  setup do
    Catalog.invalidate()
    on_exit(fn -> Catalog.invalidate() end)
    :ok
  end

  test "snapshot includes the global meta-keys with descriptions and values" do
    %{keys: keys} = Catalog.snapshot()
    by_key = Map.new(keys, &{&1.key, &1})

    chart = Map.fetch!(by_key, "chart")
    assert chart.description == "Display results as a chart"
    assert Enum.map(chart.values, & &1.value) == ["line", "bar", "table"]

    x = Map.fetch!(by_key, "x")
    assert x.chart_followup == true

    range = Map.fetch!(by_key, "range")
    assert "7d" in Enum.map(range.values, & &1.value)
  end

  test "snapshot merges per-importer field metadata" do
    %{keys: keys} = Catalog.snapshot()
    by_key = Map.new(keys, &{&1.key, &1})

    repo_name = Map.fetch!(by_key, "repo_name")
    assert repo_name.description == "GitHub repository"

    command = Map.fetch!(by_key, "command")
    assert command.description == "Shell command"
  end

  test "snapshot omits importer fields without metadata" do
    %{keys: keys} = Catalog.snapshot()
    by_key = Map.new(keys, &{&1.key, &1})

    # `id`, `timestamp_unix`, etc. live on every importer schema but have
    # no description — they would be noise in the autocomplete dropdown.
    refute Map.has_key?(by_key, "id")
    refute Map.has_key?(by_key, "timestamp_unix")
  end

  test "invalidate forces recomputation" do
    first = Catalog.snapshot()
    Catalog.invalidate()
    second = Catalog.snapshot()
    assert first.keys == second.keys
  end
end
