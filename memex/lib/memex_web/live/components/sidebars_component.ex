defmodule MemexWeb.SidebarsComponent do
  use Surface.Component

  prop(sidebars, :list, required: true)
  prop(socket, :any, required: true)

  def render(assigns) do
    ~F"""
    <div
      phx-hook="Sidebar"
      id="sidebars"
      data-state={if length(@sidebars) > 1 do
        "open"
      else
        "closed"
      end}
      aria-hidden
    />
    <div
      :for.with_index={{hit, index} <- @sidebars}
      id={"sidebar-#{index}"}
      class={
        "fixed inset-0 transition backdrop-filter backdrop-blur-md",
        "backdrop-filter-none pointer-events-none": hit["closed"],
        "bg-black/50": not hit["closed"]
      }
    >
      <div phx-click="close-last-sidebar" class="fixed inset-0 text-white" />
      <div class={"fixed border-l dark:border-gray-700 dark:bg-gray-800 bg-gray-50 p-5 inset-y-0 right-0 shadow-2xl #{width(index, length(@sidebars))} overflow-scroll transform transition-transform #{if hit["closed"] do
        "translate-x-full"
      end}"}>
        <button phx-click="close-last-sidebar" aria-label="Close" class="dark:text-white float-right">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          ><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
        </button>
        <div class="-mt-2" :if={hit["type"] === "generic"}>{live_render(@socket, MemexWeb.Sidebars.GenericLive, id: "generic", session: hit)}</div>
        <div class="-mt-2" :if={hit["type"] === "person"}>{live_render(@socket, MemexWeb.Sidebars.PersonLive, id: "person", session: %{"hit" => hit})}</div>
        <div class="-mt-2" :if={hit["type"] === "activity"}>{live_render(@socket, MemexWeb.Sidebars.ActivityLive, id: "activity", session: hit)}</div>
        <div class="-mt-2" :if={hit["type"] === "settings"}>{live_render(@socket, MemexWeb.Sidebars.SettingsLive, id: "settings")}</div>
        <div
          :if={hit["location_latitude"] && hit["location_longitude"]}
          class="rounded-md col-span-3"
          style="height: 200px"
          phx-hook="Map"
          id={"map-#{index}"}
          data-points={points(hit)}
        />
      </div>
    </div>
    """
  end

  defp width(index, length) do
    case index do
      0 -> "w-11/12"
      1 -> "w-10/12"
      2 -> "w-9/12"
      3 -> "w-8/12"
      _ -> "w-7/12"
    end
  end

  defp points(hit) do
    Jason.encode!([
      %{
        "lat" => hit["location_latitude"],
        "lon" => hit["location_longitude"]
      }
    ])
  end
end
