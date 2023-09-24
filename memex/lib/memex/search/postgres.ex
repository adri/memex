defmodule Memex.Search.Postgres do
  @moduledoc false
  import Ecto.Query

  alias Memex.Repo
  alias Memex.Schema.Document

  def query(%{} = query) do
    from(d in Document)
    |> add_search(query)
    |> add_select(query)
    |> add_filters(prepare_filters(query))
    |> add_limit(query)
    |> add_order_by(query.order_by)
    |> add_relations(query)
    |> run(query)
    |> format_results(query)
  end

  def find(id) do
    case Repo.get(Document, id) do
      nil -> {:error, :not_found}
      doc -> {:ok, doc.body}
    end
  end

  defp add_search(q, %{query: ""} = _query), do: q

  defp add_search(q, %{query: query} = _query) do
    from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^to_tsquery(query)))
  end

  defp add_search(q, %{} = _query), do: q

  defp add_select(q, %{select: :hits_with_highlights} = _query) do
    from(q in q, select: q)
  end

  defp add_select(q, %{select: [facet: "month"]} = _query) do
    from(q in q,
      select: {fragment("to_char(date_trunc('month', created_at), 'yyyy-mm')"), count(q.id)},
      group_by: fragment("date_trunc('month', created_at)")
    )
  end

  defp add_select(q, %{select: [facet: "provider"]} = _query) do
    from(q in q,
      select: {fragment("? -> 'provider'", q.body), count(q.id)},
      group_by: fragment("? -> 'provider'", q.body)
    )
  end

  defp add_select(q, %{select: :total_hits} = _query) do
    from(q in q, select: count(q.id))
  end

  defp add_select(q, %{} = _query) do
    from(q in q, select: q.body)
  end

  defp run(q, %{select: :total_hits} = _query) do
    Repo.one!(q)
  end

  defp run(q, %{} = _query) do
    Repo.all(q)
  end

  # defp prepare_filters(%{select: [facet: "month"]} = query), do: Map.delete(query.filters, "month")

  defp prepare_filters(%{} = query), do: query.filters

  defp add_filters(q, filters) do
    Enum.reduce(filters, q, fn
      %{"type" => "Prefix", "value" => value}, q ->
        from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^(value <> ":*")))

      %{"type" => "NotPrefix", "value" => value}, q ->
        from(q in q, where: fragment("not ? @@ to_tsquery('simple', ?)", q.search, ^(value <> ":*")))

      %{"type" => "Exact", "value" => value}, q ->
        from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^("'" <> value <> "'")))

      %{"type" => "NotExact", "value" => value}, q ->
        from(q in q, where: fragment("not ? @@ to_tsquery('simple', ?)", q.search, ^("'" <> value <> "'")))

      %{"type" => "Equals", "key" => "month", "value" => month}, q ->
        from(q in q, where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^month))

      %{"type" => "Equals", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \= ?::jsonb", q.body, ^key, ^value))

      %{"type" => "NotEquals", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \!\= ?::jsonb", q.body, ^key, ^value))

      %{"type" => "GreaterThan", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \> ?", q.body, ^key, ^value))

      %{"type" => "GreaterThanEquals", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \>= ?", q.body, ^key, ^value))

      %{"type" => "LessThan", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \< ?", q.body, ^key, ^value))

      %{"type" => "LessThanEquals", "key" => key, "value" => value}, q ->
        from(q in q, where: fragment("? -> ? \<= ?", q.body, ^key, ^value))

      {"date", date}, q ->
        from(q in q, where: fragment("to_char(?.created_at, 'yyyy-mm-dd') = ?", q, ^date))

      {"time", time}, q ->
        case DateTime.from_iso8601(time) do
          {:ok, parsed, _} ->
            from(q in q, where: fragment("?.created_at <= ?", q, ^parsed))

          {:error, _error} ->
            q
        end

      {"person_name", name}, q ->
        from(q in q,
          where:
            fragment("? -> 'person_name' \\? ?", q.body, ^name) or
              fragment("? -> 'tweet_user_name' \\? ?", q.body, ^name)
        )

      {"created_at_between", [from_date, to_date]}, q ->
        from(q in q, where: q.created_at >= ^from_date and q.created_at <= ^to_date)

      {"created_at_within", date}, q ->
        from(q in q,
          where:
            q.created_at >= ^date and
              fragment("(? ->> 'timestamp_start_utc')::timestamp <= ?", q.body, ^date)
        )

      {key, name}, q ->
        from(q in q, where: fragment("? -> ?::text \\? ?", q.body, ^key, ^name))

      _, q ->
        q
    end)
  end

  defp add_order_by(q, sort) do
    Enum.reduce(sort, q, fn
      "created_at_desc", q ->
        from(q in q, order_by: [desc: q.created_at])

      _, q ->
        q
    end)
  end

  defp add_relations(q, %{select: :hits_with_highlights} = _query) do
    from(o in subquery(q),
      left_join: r in assoc(o, :relations),
      left_join: rd in assoc(r, :source),
      select: %{
        "hit" => o.body,
        "relations" => fragment("COALESCE(json_agg(json_build_object(
            'type', ?,
            'related', ?
          )) FILTER (WHERE ? IS NOT NULL), '[]')", r.type, rd.body, rd.id)
      },
      group_by: [o.body, o.created_at],
      order_by: [desc: o.created_at]
    )
  end

  defp add_relations(q, %{} = _query), do: q

  def add_limit(q, %{limit: nil} = _query), do: q
  def add_limit(q, %{limit: limit} = _query), do: from(q in q, limit: ^limit)

  def to_tsquery(query) do
    terms =
      query
      |> String.trim()
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&(&1 <> ":*"))

    []
    |> Enum.concat(terms)
    |> Enum.join(" & ")
    |> String.trim()
  end

  defp format_results(results, %{select: :hits_with_highlights} = query) do
    results
    |> Enum.map(&put_in(&1, ["hit", "_formatted"], format_hit(&1["hit"], query)))
    |> Enum.map(&put_in(&1, ["hit", "_relations"], &1["relations"]))
    |> Enum.map(&get_in(&1, ["hit"]))
  end

  defp format_results(results, %{select: [facet: "month"]} = _query) do
    month_range_cached()
    |> Map.new()
    |> Map.merge(Map.new(results))
    |> Enum.sort(&(&1 > &2))
  end

  defp format_results(results, %{} = _query), do: results

  # Surround all values in the map that match the words in the query with <em></em>
  defp format_hit(hit, %{query: ""} = _query), do: hit

  defp format_hit(hit, %{query: query} = _query) do
    words_to_highlight =
      query
      |> String.replace("\"", "")
      |> String.split(~r/\s+/, trim: true)

    for {key, value} <- hit, into: %{}, do: {key, highlight(value, words_to_highlight)}
  end

  defp format_hit(hit, %{filters: filters} = _query) do
    words_to_highlight =
      filters
      |> Enum.filter(fn
        %{"type" => "Exact"} -> true
        %{"type" => "Prefix"} -> true
        %{"type" => "Equals"} -> true
        _ -> false
      end)
      |> Enum.map(fn %{"value" => word} -> word end)

    for {key, value} <- hit, into: %{}, do: {key, highlight(value, words_to_highlight)}
  end

  defp format_hit(hit, %{} = _query), do: hit

  defp highlight(other, []), do: other

  defp highlight(text, words_to_highlight) when is_binary(text) do
    encoded = Enum.map_join(words_to_highlight, "|", &Regex.escape/1)

    String.replace(text, ~r/(#{encoded})/i, "<em>\\1</em>")
  end

  defp highlight(list, words_to_highlight) when is_list(list) do
    Enum.map(list, &highlight(&1, words_to_highlight))
  end

  defp highlight(other, _words), do: other

  defp month_range_cached do
    ConCache.get_or_store(:search, "month_range", &month_range/0)
  end

  defp month_range do
    earliest = Repo.one(from(d in Document, order_by: [asc: d.created_at], limit: 1))

    Enum.map(Month.Range.new!(Month.new!(earliest.created_at), Month.utc_now!()).months, fn m ->
      {Month.to_string(m), 0}
    end)
  end
end
