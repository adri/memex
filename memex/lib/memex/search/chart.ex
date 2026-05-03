defmodule Memex.Search.Chart do
  @moduledoc """
  Chart query builder. Detects chart filters in a parsed query and produces
  aggregated time-series data with comparison vs the previous period.

  Recognised keys: `chart`, `x`, `y`, `from`, `range`. Any other filters are
  applied as additional `WHERE` clauses against `documents.body`.
  """
  import Ecto.Query

  alias Memex.Repo
  alias Memex.Schema.Document

  # Keys consumed by the chart spec itself. Everything else (`provider`,
  # `verb`, free-text terms, …) is left in `spec.filters` and applied as a
  # normal where-clause against `documents.body`.
  @chart_keys ~w(chart x y range)

  defmodule Spec do
    @moduledoc false
    defstruct type: "line",
              x: :day,
              y: :count,
              filters: [],
              range_days: 7
  end

  def chart?(filters) do
    Enum.any?(filters, fn
      %{"key" => key} -> key in @chart_keys
      _ -> false
    end)
  end

  def build_spec(filters) do
    Enum.reduce(filters, %Spec{}, fn
      %{"key" => "chart", "value" => v}, acc -> %{acc | type: parse_type(v)}
      %{"key" => "x", "value" => v}, acc -> %{acc | x: parse_bucket(v)}
      %{"key" => "y", "value" => v}, acc -> %{acc | y: parse_y(v)}
      %{"key" => "range", "value" => v}, acc -> %{acc | range_days: parse_range(v)}
      filter, acc -> %{acc | filters: acc.filters ++ [filter]}
    end)
  end

  def query(%Spec{} = spec, now \\ DateTime.utc_now()) do
    end_at = floor_to_day(now) |> DateTime.add(86_400, :second)
    start_at = DateTime.add(end_at, -spec.range_days * 86_400, :second)
    prev_end = start_at
    prev_start = DateTime.add(prev_end, -spec.range_days * 86_400, :second)

    current_buckets = bucket_counts(spec, start_at, end_at)
    previous_buckets = bucket_counts(spec, prev_start, prev_end)

    labels = build_buckets(spec.x, start_at, end_at)
    current = Enum.map(labels, &Map.get(current_buckets, bucket_key(&1, spec.x), 0))
    previous = align_previous(labels, previous_buckets, spec)

    current_total = Enum.sum(current)
    previous_total = Enum.sum(previous)

    %{
      type: spec.type,
      labels: Enum.map(labels, &format_label(&1, spec.x)),
      current: current,
      previous: previous,
      current_total: current_total,
      previous_total: previous_total,
      delta_pct: delta_pct(current_total, previous_total),
      range_label: format_range(start_at, end_at),
      previous_range_label: format_range(prev_start, prev_end),
      daily_average: daily_average(current_total, spec),
      unit_label: unit_label(spec),
      title: build_title(spec)
    }
  end

  defp bucket_counts(spec, start_at, end_at) do
    Document
    |> where([d], d.created_at >= ^start_at and d.created_at < ^end_at)
    |> apply_filters(spec.filters)
    |> bucket_group(spec.x)
    |> Repo.all()
    |> Map.new()
  end

  defp bucket_group(q, :day) do
    q
    |> group_by([d], fragment("to_char(date_trunc('day', ?), 'YYYY-MM-DD')", d.created_at))
    |> select(
      [d],
      {fragment("to_char(date_trunc('day', ?), 'YYYY-MM-DD')", d.created_at), count(d.id)}
    )
  end

  defp bucket_group(q, :week) do
    q
    |> group_by([d], fragment("to_char(date_trunc('week', ?), 'YYYY-MM-DD')", d.created_at))
    |> select(
      [d],
      {fragment("to_char(date_trunc('week', ?), 'YYYY-MM-DD')", d.created_at), count(d.id)}
    )
  end

  defp bucket_group(q, :month) do
    q
    |> group_by([d], fragment("to_char(date_trunc('month', ?), 'YYYY-MM')", d.created_at))
    |> select(
      [d],
      {fragment("to_char(date_trunc('month', ?), 'YYYY-MM')", d.created_at), count(d.id)}
    )
  end

  defp apply_filters(q, filters) do
    Enum.reduce(filters, q, fn
      %{"type" => "Equals", "key" => key, "value" => value}, q ->
        # Postgrex's JSONB encoder takes the raw value and JSON-encodes
        # it once. Doing our own Jason.encode! here would double-encode
        # strings (`"\"terminal\""`) and never match.
        where(q, [d], fragment("? -> ? = ?::jsonb", d.body, ^key, ^value))

      %{"type" => "Prefix", "value" => value}, q ->
        where(q, [d], fragment("? @@ to_tsquery('simple', ?)", d.search, ^(value <> ":*")))

      _, q ->
        q
    end)
  end

  defp align_previous(current_labels, previous_buckets, spec) do
    Enum.map(current_labels, fn label ->
      shifted = DateTime.add(label, -spec.range_days * 86_400, :second)
      Map.get(previous_buckets, bucket_key(shifted, spec.x), 0)
    end)
  end

  defp build_buckets(:day, start_at, end_at) do
    Stream.iterate(floor_to_day(start_at), &DateTime.add(&1, 86_400, :second))
    |> Stream.take_while(&(DateTime.compare(&1, end_at) == :lt))
    |> Enum.to_list()
  end

  defp build_buckets(:week, start_at, end_at) do
    Stream.iterate(floor_to_week(start_at), &DateTime.add(&1, 7 * 86_400, :second))
    |> Stream.take_while(&(DateTime.compare(&1, end_at) == :lt))
    |> Enum.to_list()
  end

  defp build_buckets(:month, start_at, end_at) do
    floor_to_month(start_at)
    |> Stream.iterate(&add_months(&1, 1))
    |> Stream.take_while(&(DateTime.compare(&1, end_at) == :lt))
    |> Enum.to_list()
  end

  defp bucket_key(dt, :day), do: Calendar.strftime(dt, "%Y-%m-%d")
  defp bucket_key(dt, :week), do: Calendar.strftime(floor_to_week(dt), "%Y-%m-%d")
  defp bucket_key(dt, :month), do: Calendar.strftime(dt, "%Y-%m")

  defp floor_to_day(dt), do: %{dt | hour: 0, minute: 0, second: 0, microsecond: {0, 0}}

  defp floor_to_week(dt) do
    days_back = Date.day_of_week(DateTime.to_date(dt)) - 1
    DateTime.add(floor_to_day(dt), -days_back * 86_400, :second)
  end

  defp floor_to_month(dt), do: %{floor_to_day(dt) | day: 1}

  defp add_months(dt, n) do
    {y, m} = {dt.year, dt.month + n}
    extra = div(m - 1, 12)
    new_month = rem(m - 1, 12) + 1
    %{dt | year: y + extra, month: new_month}
  end

  defp format_label(dt, :day), do: Calendar.strftime(dt, "%b %-d")
  defp format_label(dt, :week), do: Calendar.strftime(dt, "%b %-d")
  defp format_label(dt, :month), do: Calendar.strftime(dt, "%b %Y")

  defp format_range(s, e) do
    e_inclusive = DateTime.add(e, -86_400, :second)

    if s.year == e_inclusive.year do
      "#{Calendar.strftime(s, "%b %-d")} – #{Calendar.strftime(e_inclusive, "%b %-d, %Y")}"
    else
      "#{Calendar.strftime(s, "%b %-d, %Y")} – #{Calendar.strftime(e_inclusive, "%b %-d, %Y")}"
    end
  end

  defp delta_pct(_, 0), do: nil
  defp delta_pct(current, previous), do: round((current - previous) / previous * 100)

  defp daily_average(total, %{range_days: days}) when days > 0 do
    Float.round(total / days, 1)
  end

  defp daily_average(_, _), do: 0.0

  defp unit_label(spec) do
    case provider_filter(spec) do
      nil -> "documents"
      p -> humanize_unit(p)
    end
  end

  defp build_title(spec) do
    case provider_filter(spec) do
      nil -> "Documents #{cadence(spec.x)}"
      p -> "#{humanize_segment(p)} #{cadence(spec.x)}"
    end
  end

  defp provider_filter(%Spec{filters: filters}) do
    Enum.find_value(filters, fn
      %{"type" => "Equals", "key" => "provider", "value" => v} -> v
      _ -> nil
    end)
  end

  defp cadence(:day), do: "per day"
  defp cadence(:week), do: "per week"
  defp cadence(:month), do: "per month"

  defp humanize_segment(s), do: s |> String.replace("_", " ") |> String.capitalize()

  defp humanize_unit(s), do: s |> String.replace("_", " ")

  defp parse_type("bar"), do: "bar"
  defp parse_type("table"), do: "table"
  defp parse_type(_), do: "line"

  defp parse_bucket("day"), do: :day
  defp parse_bucket("week"), do: :week
  defp parse_bucket("month"), do: :month
  defp parse_bucket(_), do: :day

  defp parse_y(_), do: :count

  defp parse_range(value) do
    case Regex.run(~r/^(\d+)\s*([dwmy])$/i, value) do
      [_, n, unit] ->
        n = String.to_integer(n)

        case String.downcase(unit) do
          "d" -> n
          "w" -> n * 7
          "m" -> n * 30
          "y" -> n * 365
        end

      _ ->
        7
    end
  end

end
