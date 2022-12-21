defmodule Memex.Search.Postgres do
  alias Memex.Schema.Document
  alias Memex.Repo
  alias Memex.Search.Query
  import Ecto.Query

  def query(query = %Query{}) do
    from(d in Document)
    |> add_search(query)
    |> add_select(query)
    # |> add_vector_search(query)
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

  defp add_search(q, %Query{query: ""} = _query), do: q

  defp add_search(q, %Query{} = query) do
    from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^to_tsquery(query)))
  end

  defp add_vector_search(q, %Query{query: ""} = _query), do: q

  defp add_vector_search(q, %Query{} = query) do
    from(q in q, where: fragment("? <=> ? > 0.6", q.search_embedding, ^to_vector(query)))
  end

  defp add_select(q, %Query{select: :hits_with_highlights} = _query) do
    from(q in q, select: q)
  end

  defp add_select(q, %Query{select: [facet: "month"]} = _query) do
    from(q in q,
      select: {fragment("to_char(date_trunc('month', created_at), 'yyyy-mm')"), count(q.id)},
      group_by: fragment("date_trunc('month', created_at)")
    )
  end

  defp add_select(q, %Query{select: [facet: "provider"]} = _query) do
    from(q in q,
      select: {fragment("? -> 'provider'", q.body), count(q.id)},
      group_by: fragment("? -> 'provider'", q.body)
    )
  end

  defp add_select(q, %Query{select: :total_hits} = _query) do
    from(q in q, select: count(q.id))
  end

  defp add_select(q, %Query{} = _query) do
    from(q in q, select: q.body)
  end

  defp run(q, %Query{select: :total_hits} = _query) do
    Repo.one!(q)
  end

  defp run(q, %Query{} = _query) do
    Repo.all(q)
  end

  defp prepare_filters(%Query{select: [facet: "month"]} = query),
    do: Map.delete(query.filters, "month")

  defp prepare_filters(%Query{} = query), do: query.filters

  defp add_filters(q, filters) do
    Enum.reduce(filters, q, fn
      {"month", month}, q ->
        from(q in q, where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^month))

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

  defp add_relations(q, %Query{select: :hits_with_highlights} = _query) do
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

  defp add_relations(q, %Query{} = _query), do: q

  def add_limit(q, %Query{limit: nil} = _query), do: q
  def add_limit(q, %Query{limit: limit} = _query), do: from(q in q, limit: ^limit)

  def to_tsquery(%Query{} = query) do
    terms =
      query.query
      |> String.trim()
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&(&1 <> ":*"))

    []
    |> Enum.concat(terms)
    |> Enum.join(" & ")
    |> String.trim()
  end

  defp to_vector(%Query{} = query) do
    Memex.Ai.SentenceTransformers.embed(query.query)
  end

  defp format_results(results, %Query{select: :hits_with_highlights} = query) do
    results
    |> Enum.map(&put_in(&1, ["hit", "_formatted"], format_hit(&1["hit"], query)))
    |> Enum.map(&put_in(&1, ["hit", "_relations"], &1["relations"]))
    |> Enum.map(&get_in(&1, ["hit"]))
  end

  defp format_results(results, %Query{select: [facet: "month"]} = _query) do
    Map.merge(Map.new(month_range_cached()), Map.new(results))
    |> Enum.sort(&(&1 > &2))
  end

  defp format_results(results, %Query{} = _query), do: results

  # Surround all values in the map that match the words in the query with <em></em>
  defp format_hit(hit, %Query{query: ""} = _query), do: hit

  defp format_hit(hit, %Query{query: query} = _query) do
    words =
      query
      |> String.replace("\"", "")
      |> String.split(~r/\s+/, trim: true)

    for {k, v} <- hit, into: %{}, do: {k, format_hit_value(v, words)}
  end

  defp format_hit_value(value, words) when is_binary(value) do
    encoded =
      words
      |> Enum.map(&Regex.escape/1)
      |> Enum.join("|")

    String.replace(value, ~r/(#{encoded})/i, "<em>\\1</em>")
  end

  defp format_hit_value(value, words) when is_list(value),
    do: Enum.map(value, &format_hit_value(&1, words))

  defp format_hit_value(value, _words), do: value

  defp month_range_cached() do
    ConCache.get_or_store(:search, "month_range", &month_range/0)
  end

  defp month_range() do
    earliest =
      from(d in Document, order_by: [asc: d.created_at], limit: 1)
      |> Repo.one()

    Month.Range.new!(
      Month.new!(earliest.created_at),
      Month.utc_now!()
    ).months
    |> Enum.map(fn m -> {Month.to_string(m), 0} end)
  end
end
