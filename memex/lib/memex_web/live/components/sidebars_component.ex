defmodule MemexWeb.SidebarsComponent do
  use Surface.Component

  prop(sidebars, :list, required: true)

  def render(assigns) do
    ~F"""
    <div phx-hook="Sidebar" id="sidebars" data-open={length(@sidebars) > 1} aria-hidden></div>
    <div :for.with_index={{hit, index} <- @sidebars}
      id={"sidebar-#{index}"}
      class={"fixed inset-0 transition backdrop-filter backdrop-blur-sm", "backdrop-filter-none pointer-events-none": hit["closed"], "bg-black bg-opacity-30": not hit["closed"]}>

      <div phx-click="close-last-sidebar" class="fixed inset-0 text-white"></div>
      <div class={"fixed border-l dark:border-gray-700 dark:bg-gray-800 bg-gray-50 p-5 inset-y-0 right-0 shadow-2xl #{width(index)} overflow-scroll transform transition-transform #{if hit["closed"] do "translate-x-full" end}"}>
        <div class="flex place-items-start justify-between">
          <span class="flex-none"></span>
          <button phx-click="close-last-sidebar" aria-label="Close" class="dark:text-white">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>
        <div :if={hit["type"] === "person"}>{live_render(@socket, MemexWeb.Sidebars.PersonLive, id: "1234", session: %{"hit" => hit})}</div>
        <div :if={hit["location_latitude"] && hit["location_longitude"]} class="rounded-md col-span-3" style="height: 200px" phx-hook="Map" id={"map-#{index}"} data-points={points(hit)}></div>
      </div>
    </div>
    """
  end

  defp width(index) do
    case index do
      0 -> "w-10/12"
      1 -> "w-9/12"
      2 -> "w-8/12"
      3 -> "w-7/12"
      _ -> "w-6/12"
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
