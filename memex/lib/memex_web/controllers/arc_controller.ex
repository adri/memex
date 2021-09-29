defmodule MemexWeb.ArcController do
  use MemexWeb, :controller

  @arc_export_path "/Users/adrimbp/Library/Mobile\ Documents/iCloud~com~bigpaua~LearnerCoacher/Documents/Export/"

  def geopoint(conn, %{"date" => date, "id" => timeline_item_id} = _params) do
    find_timeline_item(date, timeline_item_id)
    |> case do
      {:ok, item} ->
        conn
        |> put_resp_content_type("application/json", "utf-8")
        |> json(item)

      {:error, _error} ->
        conn
        |> send_resp(404, "Not found")
    end
  end

  def gpx(conn, %{"date" => date, "id" => _timeline_item_id} = _params) do
    path = @arc_export_path <> "GPX/Daily/" <> date <> ".gpx"

    path
    |> File.read()
    |> case do
      {:ok, content} ->
        content |> IO.inspect(label: "16")

        conn
        |> put_resp_content_type("application/gpx+xml", "utf-8")
        |> send_resp(200, content)

      {:error, _error} ->
        conn
        |> send_resp(404, "Not found")
    end
  end

  def geojson(conn, %{"date" => date, "id" => timeline_item_id} = _params) do
    find_timeline_item(date, timeline_item_id)
    |> case do
      {:ok, item} ->
        conn
        |> json(%{
          "type" => "Feature",
          "properties" => %{},
          "geometry" => %{
            "type" => "LineString",
            "coordinates" =>
              item["samples"]
              |> Enum.map(fn sample ->
                [sample["location"]["longitude"], sample["location"]["latitude"]]
              end)
          }
        })

      {:error, _error} ->
        conn
        |> send_resp(404, "Not found")
    end
  end

  defp find_timeline_item(date, "arc-" <> timeline_item_id) do
    path = @arc_export_path <> "JSON/Daily/" <> date <> ".json.gz"

    path
    |> File.stream!([:compressed])
    |> Enum.into("")
    |> Jason.decode()
    |> case do
      {:ok, content} ->
        item =
          content["timelineItems"]
          |> Enum.find(fn item -> item["itemId"] == timeline_item_id end)

        {:ok, item}

      {:error, error} ->
        {:error, error}
    end
  end
end
