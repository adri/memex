defmodule Memex.Search.Postgres do
  alias Memex.Schema.Document
  alias Memex.Repo
  alias Memex.Search.Query
  import Ecto.Query

  def query(query = %Query{}) do
    from(d in Document)
    |> add_search(query)
    |> add_select(query)
    |> add_relations(query)
    |> add_filters(prepare_filters(query))
    |> add_limit(query)
    |> add_order_by(query.order_by)
    |> run(query)
    |> format_results(query)
  end

  def find(id) do
    case Repo.get(Document, id) do
      nil -> {:error, :not_found}
      doc -> {:ok, doc.body}
    end
  end

  def find_person(name, limit \\ 10) do
    {processing_time, [counts, last, places]} =
      :timer.tc(fn ->
        Task.await_many([
          Task.async(fn -> count_by_name(name) end),
          Task.async(fn -> last_by_name(name, limit) end),
          Task.async(fn ->
            _places =
              from(d in Document,
                select: {fragment("body ->> 'place_name'"), count(d.id)},
                where:
                  fragment("body -> 'person_name' \\? ?", ^name) or
                    fragment("body -> 'tweet_user_name' \\? ?", ^name),
                group_by: fragment("body ->> 'place_name'")
              )
              |> Repo.all()
              |> Enum.into(%{})
          end)
        ])
      end)

    {:ok,
     %{
       "provider_counts" => counts,
       "last_actions" => last,
       "top_places" => places,
       "processing_time" => processing_time / 1000
     }}
  end

  def last_by_name(name, limit) do
    from(d in Document,
      select: d.body,
      where:
        fragment("body -> 'person_name' \\? ?", ^name) or
          fragment("body -> 'tweet_user_name' \\? ?", ^name),
      order_by: [desc: d.created_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  def count_by_name(name) do
    from(d in Document,
      select: {fragment("body ->> 'provider'"), count(d.id)},
      where:
        fragment("body -> 'person_name' \\? ?", ^name) or
          fragment("body -> 'tweet_user_name' \\? ?", ^name),
      group_by: fragment("body ->> 'provider'")
    )
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp add_search(q, %Query{query: ""} = _query), do: q

  defp add_search(q, %Query{} = query) do
    from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^to_tsquery(query)))
  end

  defp add_select(q, %Query{select: :hits_with_highlights} = query) do
    from(q in q,
      select: %{
        "hit" => q.body,
        "formatted" =>
          fragment(
            "ts_headline(?, to_tsquery('simple', ?), 'StartSel=<em>, StopSel=</em>')",
            q.body,
            ^to_tsquery_inverse(query)
          )
      }
    )
  end

  defp add_select(q, %Query{select: [facet: "month"]} = _query) do
    from(q in q,
      select: {fragment("to_char(date_trunc('month', created_at), 'yyyy-mm')"), count(q.id)},
      group_by: fragment("date_trunc('month', created_at)")
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
      {"month", date_month}, q ->
        from(q in q,
          where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^date_month)
          # todo: can this be done with more efficient query?
        )

      {"person_name", name}, q ->
        from(q in q,
          where:
            fragment("? -> 'person_name' \\? ?", q.body, ^name) or
              fragment("? -> 'tweet_user_name' \\? ?", q.body, ^name)
        )

      {key, name}, q ->
        from(q in q,
          where: fragment("? -> ?::text \\? ?", q.body, ^key, ^name)
        )

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
    from(q in q,
      left_join: r in assoc(q, :relations),
      left_join: rd in assoc(r, :source),
      select_merge: %{
        "relations" => fragment("COALESCE(json_agg(json_build_object(
            'type', ?,
            'related', ?
          )) FILTER (WHERE ? IS NOT NULL), '[]')", r.type, rd.body, rd.id)
      },
      group_by: [q.body, q.created_at]
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

  defp to_tsquery_inverse(%Query{} = query) do
    to_tsquery(query)
    |> String.replace(" & ", " | ")
  end

  defp format_results(results, %Query{select: :hits_with_highlights} = _query) do
    results
    |> Enum.map(&put_in(&1, ["hit", "_formatted"], &1["formatted"]))
    |> Enum.map(&put_in(&1, ["hit", "_relations"], &1["relations"]))
    |> Enum.map(&get_in(&1, ["hit"]))
  end

  defp format_results(results, %Query{select: [facet: "month"]} = _query) do
    Map.merge(Map.new(month_range_cached()), Map.new(results))
    |> Enum.sort(&(&1 > &2))
  end

  defp format_results(results, %Query{} = _query), do: results

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
