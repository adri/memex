defmodule Memex.Importers.MoneyMoney do
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
    field :transaction_account_name, :string
    field :transaction_category, :string
    field :transaction_amount, :float
    field :transaction_currency, :string
    field :transaction_recipient, :string
    field :transaction_reference, :string
    field :transaction_purpose, :string
  end

  def provider(), do: "MoneyMoney"

  def default_config() do
    %{
      "location" => "/Users/adrimbp/workspace/learn_memex/meilisearch/memex/MoneyMoney.sqlite",
      "database_password" => "set_your_password_here",
      "bank_timezone" => "Europe/Amsterdam",
      "schedule" => :watcher
    }
  end

  def fetch(config) do
    %Importer.Sqlite{
      location: config["location"],
      key: config["database_password"],
      setup: [],
      query: """
      SELECT
          json_object(
              'provider', 'MoneyMoney',
              'verb', 'transacted',
              'id', 'moneymoney-' || transactions.rowid,
              'date_month', strftime('%Y-%m', transactions.timestamp, 'unixepoch', 'utc'),
              'timestamp_utc', datetime(transactions.timestamp, 'unixepoch', 'utc'),
              'timestamp_unix', transactions.timestamp,
              'transaction_account_name', accounts.name,
              'transaction_category', categories.name,
              'transaction_amount', transactions.amount,
              'transaction_currency', transactions.currency,
              'transaction_recipient', transactions.name,
              'transaction_reference', transactions.eref,
              'transaction_purpose', transactions.unformatted_purpose
        ) AS json
      FROM transactions
      LEFT JOIN accounts ON transactions.local_account_key=accounts.rowid
      LEFT JOIN categories ON transactions.category_key=categories.rowid
      """
    }
  end

  def transform(results, config) do
    time_zone = config["bank_timezone"]

    results
    |> Enum.map(fn result -> parse_time(result, "transaction_purpose", time_zone) end)
    |> Enum.map(fn result -> parse_time(result, "transaction_reference", time_zone) end)
  end

  @german_datetime_regex ~r/(?<day>\d{2})-(?<month>\d{2})-(?<year>\d{4}) (?<hours>\d{2}):(?<minutes>\d{2})/
  defp parse_time(result, key, bank_timezone) do
    case Regex.named_captures(@german_datetime_regex, result[key]) do
      %{"day" => day, "month" => month, "year" => year, "hours" => hours, "minutes" => minutes} ->
        datetime =
          "#{year}-#{month}-#{day}T#{hours}:#{minutes}:00"
          |> NaiveDateTime.from_iso8601!()
          |> DateTime.from_naive!(bank_timezone)

        result
        |> Map.put("timestamp_unix", DateTime.to_unix(datetime))
        |> Map.put(
          "timestamp_utc",
          datetime |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        )

      _ ->
        result
    end
  end

  defmodule TimeLineItem do
    use Surface.Component

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <span class="font-mono">{MemexWeb.TimelineView.number_to_currency(
          abs(@item["transaction_amount"]),
          @item["transaction_currency"]
        )}</span>
      {if @item["transaction_amount"] < 0 do
        "to "
      else
        "from "
      end}
      <span>{raw(@item["_formatted"]["transaction_recipient"])}</span>
      <span
        :if={@item["_formatted"]["transaction_category"]}
        class="float-right rounded-full dark:bg-gray-700 p-2 text-xs"
      >{raw(@item["_formatted"]["transaction_category"])}</span>
      <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
        {raw(@item["_formatted"]["transaction_account_name"])} - {raw(@item["_formatted"]["transaction_purpose"])}
      </div>
      """
    end
  end
end
