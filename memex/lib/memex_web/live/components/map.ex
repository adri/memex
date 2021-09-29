defmodule MemexWeb.Map do
  use Surface.Component
  alias MemexWeb.Router.Helpers, as: Routes

  prop geojson_path, :string, required: true
  prop items, :list, default: []
  prop height, :integer, default: 250

  def render(assigns) do
    ~F"""
    <div class="rounded-md overflow-hidden mb-2 min-w-full dark:bg-gray-900" style={"height: #{@height}px"}>
      <div
        class="relative flex-grow rounded-md"
        style={"height: #{@height}px"}
        phx-hook="Map"
        phx-update="ignore"
        id="map"
        data-items={format_items(@items)}
        data-url={@geojson_path}
      />
    </div>
    """
  end

  defp format_items(items) do
    items
    |> Enum.map(&item_to_geojson(&1))
    |> Enum.filter(fn item -> item !== false end)
    |> Jason.encode!()
  end

  defp item_to_geojson(%{"provider" => "Photos"} = item) do
    %{
      "type" => "geojson",
      "data" => %{
        "type" => "Feature",
        "geometry" => %{
          "type" => "Point",
          "coordinates" => [item["location_longitude"], item["location_latitude"]]
        },
        "properties" => %{
          "style" => %{
            "width" => "40px",
            "height" => "40px",
            "backgroundImage" =>
              "url(#{Routes.photo_path(MemexWeb.Endpoint, :image, item["photo_file_path"])})",
            "backgroundSize" => "100%",
            "borderColor" => "white",
            "borderWidth" => "2px",
            "borderRadius" => "0.125rem"
          }
        }
      }
    }
  end

  defp item_to_geojson(_item), do: false
end
