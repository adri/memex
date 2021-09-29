defmodule MemexWeb.Sidebars.ActivityLive do
  use MemexWeb, :surface_live_view

  alias Memex.Search.Postgres
  alias Memex.Search.Query
  alias MemexWeb.Timeline
  alias MemexWeb.Map
  alias MemexWeb.Timeline.Card
  alias MemexWeb.TimeDuration

  def mount(params, session, socket) do
    {:ok, doc} = Postgres.find(session["id"] || params["id"])
    {:ok, previous} = Postgres.find(doc["id_previous"])
    {:ok, next} = Postgres.find(doc["id_next"])
    # doc |> IO.inspect(label: "15")
    # previous |> IO.inspect(label: "16")
    # next |> IO.inspect(label: "17")

    {:ok,
     socket
     |> assign(doc: doc, next: next, previous: previous)
     |> async_query(:items, [], %Query{
       limit: 20,
       filters: %{"created_at_between" => [doc["timestamp_start_utc"], doc["timestamp_utc"]]},
       order_by: ["created_at_desc"]
     })}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="inline-flex items-center space-x-3 mb-2">
      <!-- todo: Icon for activity type -->
      <h2 class="text-xl flex-grow dark:text-white leading-7">
        {String.capitalize(@doc["activity_type"])}
        {#unless is_nil(@previous["place_name"] || @previous["place_address"])}from <b>{@previous["place_name"] || @previous["place_address"]}</b>{/unless}
        {#unless is_nil(@next["place_name"])} to <b>{@next["place_name"]}</b>{/unless}
      </h2>

    </div>

    <Map height={250} items={@items} geojson_path={Routes.arc_path(MemexWeb.Endpoint, :geojson, date: String.slice(@doc["timestamp_utc"], 0..9), id: @doc["id"])} />

    <div class="flex w-full space-x-3">
      <div class="w-8/12">
        <Timeline items={@items} />
      </div>
      <div class="">
        <TimeDuration start_time={@doc["timestamp_start_unix"]} end_time={@doc["timestamp_unix"]} />
        <Card>
          <:content>
          Distance: xx<br>
          Most common speed: xx km/h<br>
          Steps: {@doc["activity_step_count"]}<br>
          Flights climbed: {@doc["activity_floors_ascended"]} up, {@doc["activity_floors_descended"]} down<br>
          Altitude: xx meters<br>
          </:content>
        </Card>
        <!-- Chart Heartrate -->
        <Card>
          <:content>
          Heartrate<br>
          Average: {@doc["activity_heart_rate_average"]}<br>
          Max: {@doc["activity_heart_rate_max"]}<br>
          </:content>
        </Card>

        <!-- Chart Trip speed -->
      </div>
    </div>
    """
  end
end
