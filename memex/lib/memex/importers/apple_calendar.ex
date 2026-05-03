defmodule Memex.Importers.AppleCalendar do
  @moduledoc false
  use Ecto.Schema

  alias Memex.Importer

  @primary_key false
  schema "calendar_event" do
    field(:provider, :string)
    field(:verb, :string)
    field(:id, :string)
    field(:date_start, :utc_datetime)
    field(:date_end, :utc_datetime)
    field(:event_title, :string)
    field(:event_description, :string)
    field(:location, :string)
    field(:attendees_names, {:array, :string})
    field(:attendees_emails, {:array, :string})
  end

  def provider, do: "Calendar"

  def default_config do
    %{
      "location" => "#{System.user_home!()}/Library/Calendars",
      "agendas" => ["Work", "Personal"],
      "schedule" => :daily
    }
  end

  def fetch(config) do
    %Importer.Sqlite{
      location: "#{config["location"]}/Calendar.sqlite",
      connection_options: [
        journal_mode: :wal,
        mode: "ro",
        immutable: 1
      ],
      query: """
      SELECT
        json_object(
          'provider', 'Calendar',
          'verb', 'scheduled',
          'id', ZCALENDARITEM.ZUUID,
          'date_start', datetime(ZCALENDARITEM.ZSTARTDATE + strftime('%s', '2001-01-01'), 'unixepoch'),
          'date_end', datetime(ZCALENDARITEM.ZENDDATE + strftime('%s', '2001-01-01'), 'unixepoch'),
          'event_title', ZCALENDARITEM.ZTITLE,
          'event_description', ZCALENDARITEM.ZNOTES,
          'location', ZCALENDARITEM.ZLOCATION,
          'attendees_names', json_group_array(ZATTENDEE.ZNAME),
          'attendees_emails', json_group_array(ZATTENDEE.ZEMAILADDRESS)
        ) AS json
      FROM ZCALENDARITEM
      LEFT JOIN ZATTENDEE ON ZATTENDEE.ZEVENT = ZCALENDARITEM.Z_PK
      WHERE ZCALENDARITEM.ZCALENDAR IN (
        SELECT Z_PK FROM ZCALENDAR WHERE ZTITLE IN (#{Enum.map(config["agendas"], &"'#{&1}'") |> Enum.join(", ")})
      )
      GROUP BY ZCALENDARITEM.Z_PK
      ORDER BY ZCALENDARITEM.ZSTARTDATE DESC
      LIMIT 10000
      """
    }
  end

  def transform(result, _config) do
    Enum.map(result, fn item ->
      %{
        item
        | "attendees_names" => Enum.reject(item["attendees_names"] || [], fn x -> x in ["", nil] end),
          "attendees_emails" => Enum.reject(item["attendees_emails"] || [], fn x -> x in ["", nil] end)
      }
    end)
  end
end