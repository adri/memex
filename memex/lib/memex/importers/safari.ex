defmodule Memex.Importers.Safari do
  alias Memex.Importer

  use Ecto.Schema

  @primary_key false
  schema "document" do
    field :provider, :string
    field :verb, :string
    field :id, :string
    field :date_month, :string
    field :timestamp_utc, :string
    field :timestamp_unix, :integer
    field :website_title, :string
    field :website_url, :string
    field :device_name, :string
  end

  def default_config() do
    %{
      location: "#{System.user_home!()}/Library/Safari/History.db",
      schedule: :watcher
    }
  end

  def fetch(config) do
    %Importer.Sqlite{
      location: config.location,
      setup: [],
      query: """
      SELECT
          json_object(
              'provider', 'Safari',
              'verb', 'browsed',
              'id', 'safari-' || history_visits.id,
              'date_month', strftime('%Y-%m', history_visits.visit_time + 978314400, 'unixepoch', 'utc'),
              'timestamp_utc', datetime(history_visits.visit_time + 978314400, 'unixepoch', 'utc'),
              'timestamp_unix', CAST(strftime('%s', datetime(history_visits.visit_time + 978314400, 'unixepoch', 'utc')) AS INT),
              'website_title', history_visits.title,
              'website_url', history_items.URL,
              'device_name', (CASE origin WHEN 1 THEN 'iPhone 11 Pro' WHEN 0 THEN 'MacBook Pro' END)
          )
      FROM
          history_visits
          INNER JOIN history_items ON history_items.id = history_visits.history_item
      GROUP BY
          history_visits.id
      ORDER BY
          history_visits.visit_time DESC
      LIMIT 10000
      """
    }
  end

  defmodule TimeLineItem do
    use Surface.Component

    prop doc, :map, required: true
    prop highlighted, :map

    def render(assigns) do
      ~F"""
      <div />
      """
    end
  end
end
