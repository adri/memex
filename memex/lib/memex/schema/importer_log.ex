defmodule Memex.Schema.ImporterLog do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Query

  alias Memex.Repo

  defmodule Memex.Schema.ImporterLog.Query do
    @moduledoc false
    defstruct select: :hits_with_highlights,
              filters: %{},
              aggregates: %{},
              limit: nil,
              order_by: []
  end

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "importer_log" do
    # processing, success or error
    field(:state, :string)
    field(:log, :string)
    belongs_to(:config, Memex.Schema.ImporterConfig, type: :string)
    timestamps()
  end

  def aggregate(%Memex.Schema.ImporterLog.Query{} = query) do
    from(il in __MODULE__)
    |> add_filters(query.filters)
    |> add_aggregates(query.aggregates)
    |> add_order_by(query.order_by)
  end

  defp add_filters(q, filters) do
    Enum.reduce(filters, q, fn
      {"month", month}, q ->
        from(q in q, where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^month))

      _, q ->
        q
    end)
  end

  defp add_aggregates(q, aggregates) do
    Enum.reduce(aggregates, q, fn
      {"count", month}, q ->
        from(q in q, where: fragment("to_char(?.created_at, 'yyyy-mm') = ?", q, ^month))

      _, q ->
        q
    end)
  end

  defp add_order_by(q, order_by) do
    Enum.reduce(order_by, q, fn
      "updated_at_desc", q ->
        from(q in q, order_by: [desc: q.updated_at])

      _, q ->
        q
    end)
  end

  def count_by_config do
    from(
      il in __MODULE__,
      group_by: il.config_id,
      select: {il.config_id, count(il.id)}
    )
    |> Repo.all()
    |> Map.new()
  end

  # last import date and state for each config
  def last_imports do
    from(
      il in __MODULE__,
      distinct: il.config_id,
      select:
        {il.config_id,
         %{
           "inserted_at" => il.inserted_at,
           "state" => il.state,
           "log" => il.log,
           "duration" => il.updated_at - il.inserted_at
         }},
      order_by: [desc: il.inserted_at]
    )
    |> Repo.all()
    |> Map.new()
  end
end
