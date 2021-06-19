defmodule Memex.Search.Postgres do
  alias Memex.Schema.Document
  alias Memex.Repo
  alias Memex.Search.Query
  alias Memex.Search.PostgresQuery
  import Ecto.Query

  @date_facet "month"
  @results_per_page 20

  def search(query = %Query{}, page, _surroundings) do
    limit = @results_per_page * page

    {processing_time, [hits, totalHits, facets]} =
      :timer.tc(fn ->
        Task.await_many([
          Task.async(fn -> hits(query, limit) end),
          Task.async(fn -> total(query) end),
          Task.async(fn -> facets(query) end)
        ])
      end)

    {:ok,
     %{
       "hits" => hits,
       "nbHits" => totalHits,
       "processingTimeMs" => round(processing_time / 1000),
       "facetsDistribution" => facets
     }}
  end

  def query(query = %Query{}) do
    from(d in Document, select: d.body)
    |> PostgresQuery.search(query)
    |> PostgresQuery.add_filters(query.filters)
    |> PostgresQuery.add_limit(query.limit)
    |> PostgresQuery.add_order_by(query.order_by)
    |> Repo.all()
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

  def surroundings(_timestamp) do
    {:error, :not_implemented}
  end

  defp hits(query = %Query{}, limit) do
    from(d in Document,
      select: %{
        "hit" => d.body,
        "formatted" =>
          fragment(
            "ts_headline(?, to_tsquery('simple', ?), 'StartSel=<em>, StopSel=</em>')",
            d.body,
            ^PostgresQuery.to_tsquery_inverse(query)
          )
      },
      order_by: [desc: d.created_at],
      limit: ^limit
    )
    |> PostgresQuery.search(query)
    |> PostgresQuery.add_relations()
    |> PostgresQuery.add_filters(query.filters)
    |> Repo.all()
    |> Enum.map(&put_in(&1, ["hit", "_formatted"], &1["formatted"]))
    |> Enum.map(&put_in(&1, ["hit", "_relations"], &1["relations"]))
    |> Enum.map(&get_in(&1, ["hit"]))
  end

  defp total(query = %Query{}) do
    from(d in Document, select: count(d.id))
    |> PostgresQuery.search(query)
    |> PostgresQuery.add_filters(query.filters)
    |> Repo.one!()
  end

  defp facets(query = %Query{}) do
    date_facet =
      from(d in Document,
        select: {fragment("to_char(date_trunc('month', created_at), 'yyyy-mm')"), count(d.id)},
        group_by: fragment("date_trunc('month', created_at)")
      )
      |> PostgresQuery.search(query)
      |> PostgresQuery.add_filters(Map.delete(query.filters, @date_facet))
      |> Repo.all()
      |> Enum.into(%{})

    %{"date_month" => Map.merge(month_range_cached(), date_facet)}
  end

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
    |> Map.new(fn m -> {Month.to_string(m), 0} end)
  end
end
