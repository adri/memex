defmodule Memex.Importers.Arc do
  alias Memex.Importer

  use Ecto.Schema
  @primary_key false
  schema "document" do
    field(:provider, :string)
    field(:verb, :string)
    field(:id, :string)
    field(:id_next, :string)
    field(:id_previous, :string)
    field(:date_month, :string)
    field(:timestamp_utc, :string)
    field(:timestamp_unix, :integer)
    field(:timestamp_start_unix, :integer)
    field(:timestamp_start_utc, :string)
    field(:place_name, :string)
    field(:place_address, :string)
    field(:place_latitude, :float)
    field(:place_longitude, :float)
    field(:place_altitude, :float)
    field(:place_foursquare_venue_id, :string)
    field(:place_foursquare_category_id, :string)
    field(:activity_type, :string)
    field(:activity_step_count, :integer)
    field(:activity_floors_ascended, :integer)
    field(:activity_floors_descended, :integer)
    field(:activity_heart_rate_average, :float)
    field(:activity_heart_rate_max, :float)
    field(:activity_active_energy_burned, :float)
  end

  def provider(), do: "Arc"

  def default_config() do
    %{
      "location" =>
        "#{System.user_home!()}/Library/Mobile\ Documents/iCloud~com~bigpaua~LearnerCoacher/",
      "schedule" => :watcher
    }
  end

  def fetch(config) do
    location =
      Path.wildcard("#{config["location"]}/Documents/Export/JSON/Monthly/*.json.gz")
      |> Enum.sort(:desc)
      |> Enum.at(0)

    %Importer.JsonFile{
      location: location,
      compressed: true
    }
  end

  def transform(result, config) do
    result["timelineItems"]
    |> Enum.map(&parse_item(&1, config))
    |> Enum.filter(fn item -> item != %{} end)
  end

  defp parse_common(item) do
    {:ok, start_date, _} = DateTime.from_iso8601(item["endDate"])
    {:ok, end_date, _} = DateTime.from_iso8601(item["startDate"])

    %{
      provider: "Arc",
      id: "arc-#{item["itemId"]}",
      id_next: "arc-#{item["nextItemId"]}",
      id_previous: "arc-#{item["previousItemId"]}",
      date_month: Calendar.strftime(end_date, "%Y-%m"),
      timestamp_unix: DateTime.to_unix(end_date),
      timestamp_utc: item["endDate"],
      timestamp_start_unix: DateTime.to_unix(start_date),
      timestamp_start_utc: item["startDate"],
      activity_step_count: item["stepCount"],
      activity_floors_ascended: item["floorsAscended"],
      activity_floors_descended: item["floorsDescended"],
      activity_heart_rate_average: item["averageHeartRate"],
      activity_heart_rate_max: item["maxHeartRate"],
      activity_active_energy_burned: item["activeEnergyBurned"]
    }
  end

  defp parse_item(%{"isVisit" => true, "place" => place} = item, _config) do
    parse_common(item)
    |> Map.merge(%{
      verb: "visited",
      place_altitude: item["altitude"]
    })
    |> Map.merge(parse_place(place))
  end

  defp parse_item(%{"isVisit" => true, "placeId" => placeId} = item, config) do
    path = "#{config["location"]}Documents/Backups/Place/#{String.at(placeId, 0)}/#{placeId}.json"

    {:ok, place} =
      Path.wildcard(path)
      |> Memex.Connector.json_file(false)

    parse_common(item)
    |> Map.merge(%{
      verb: "visited",
      place_altitude: item["altitude"]
    })
    |> Map.merge(parse_place(place))
  end

  defp parse_item(%{"isVisit" => false} = item, _config) do
    parse_common(item)
    |> Map.merge(%{
      verb: "moved",
      activity_type: item["activityType"]
    })
  end

  defp parse_item(_item, _config), do: %{}

  defp parse_place(place) do
    %{
      place_name: place["name"],
      place_address: place["address"],
      place_latitude: place["center"]["latitude"] || nil,
      place_longitude: place["center"]["longitude"] || nil,
      place_foursquare_venue_id: place["foursquareVenueId"],
      place_foursquare_category_id: place["foursquareCategoryId"]
    }
  end

  defmodule TimelineItem do
    use Surface.Component

    prop(item, :map)

    def render(assigns) do
      ~F"""
      <div :if={@item["verb"] === "visited" || @item["verb"] === "visit"} class="flex-grow truncate">
        {raw(@item["_formatted"]["place_name"] || @item["_formatted"]["place_address"])}
        <p class="text-xs text-gray-400 dark:text-gray-500">
          Spent {MemexWeb.TimelineView.human_time_between(@item["timestamp_unix"], @item["timestamp_start_unix"])}.
          <span :if={@item["place_name"]}>{raw(@item["_formatted"]["place_name"])}</span>
          <span :if={@item["place_address"]}>{raw(@item["_formatted"]["place_address"])}</span>
        </p>
      </div>
      <div :if={@item["verb"] === "moved"} class="flex-grow truncate">
        Finished {raw(@item["_formatted"]["activity_type"])}
        <p class="text-xs text-gray-400 dark:text-gray-500">
          {MemexWeb.TimelineView.human_time_between(@item["timestamp_unix"], @item["timestamp_start_unix"])}.
        </p>
      </div>
      """
    end
  end
end
