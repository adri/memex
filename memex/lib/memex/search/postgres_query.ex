defmodule Memex.Search.PostgresQuery do
  alias Memex.Search.Query
  import Ecto.Query

  def search(q, %Query{query: ""} = _query), do: q

  def search(q, %Query{} = query) do
    from(q in q, where: fragment("? @@ to_tsquery('simple', ?)", q.search, ^to_tsquery(query)))
  end

  def query(q, %Query{count: count_field} = _query) when is_binary(count_field) do
    from(q in q, select: count(^count_field), group_by: ^count_field)
  end

  def add_filters(q, filters) do
    Enum.reduce(filters, q, fn
      {"month", date_month}, q ->
        from(q in q,
          where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^date_month)
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

  def add_order_by(q, sort) do
    Enum.reduce(sort, q, fn
      "created_at_desc", q ->
        from(q in q, order_by: [desc: q.created_at])

      _, q ->
        q
    end)
  end

  def add_relations(q) do
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

  def add_limit(q, nil), do: q

  def add_limit(q, limit) do
    from(q in q, limit: ^limit)
  end

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

  def to_tsquery_inverse(%Query{} = query) do
    to_tsquery(query)
    |> String.replace(" & ", " | ")
  end
end
