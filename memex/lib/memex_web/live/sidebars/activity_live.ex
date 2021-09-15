defmodule MemexWeb.Sidebars.ActivityLive do
  use MemexWeb, :live_view

  alias Memex.Search.Postgres
  alias Memex.Search.Query

  @impl true
  def mount(params, session, socket) do
    {:ok, doc} = Postgres.find(session["id"] || params["id"])

    {:ok,
     socket
     |> assign(name: "test", doc: doc)
     |> async_query(:results, [], %Query{
       limit: 20,
       filters: %{"created_at_between" => [doc["timestamp_start_utc"], doc["timestamp_utc"]]}
     })}
  end

  @impl true
  def render(assigns) do
    # %{
    #   "activity_active_energy_burned" => 153.8450000000001,
    #   "activity_floors_ascended" => 3,
    #   "activity_floors_descended" => 3,
    #   "activity_heart_rate_average" => 128.34691152211295,
    #   "activity_heart_rate_max" => 156,
    #   "activity_step_count" => 2856,
    #   "activity_type" => "walking",
    #   "date_month" => "2021-06",
    #   "id" => "arc-851A756E-3D59-43AE-B856-0B4509BABE64",
    #   "id_next" => "arc-B4632356-D802-45E0-A650-D44EA491E76A",
    #   "id_previous" => "arc-52E7C0F8-3D46-42E6-9EE0-77F8C99CC3B4",
    #   "provider" => "Arc",
    #   "timestamp_start_unix" => 1624013913,
    #   "timestamp_start_utc" => "2021-06-18T10:58:33Z",
    #   "timestamp_unix" => 1624015412,
    #   "timestamp_utc" => "2021-06-18T11:23:32Z",
    #   "verb" => "moved"
    # }
    # Todo: find all timeline items within that time frame timestamp_start_unix -> timestamp_unix

    ~L"""
    <div class="flex place-items-start justify-between">
      <!-- Icon for activity type -->
      <h2 class="text-lg flex-grow dark:text-white leading-7"><%= @doc["activity_type"] %></h2>
      timestamp_start_unix -> timestamp_unix
    </div>

    <!-- todo: Load geopoints and display as map -->

          <h3 class="dark:text-white">Timeline</h3>
        <%= for hit <- @results do %>
          <div class="rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 shadow-md overflow-hidden dark:text-white">
            <p class="dark:text-white truncate"><%= hit["verb"] %></p>
          </div>
        <% end %>

    """
  end
end
