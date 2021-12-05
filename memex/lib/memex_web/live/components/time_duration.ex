defmodule MemexWeb.TimeDuration do
  use Surface.Component

  prop start_time, :datetime, required: true
  prop end_time, :datetime, required: true

  def render(assigns) do
    ~F"""
    <div class="inline-flex rounded-md bg-gray-200 dark:bg-gray-900">
      <div class="p-2 pr-1 text-gray-300">{to_time(@start_time)}</div>
      <svg
        class="self-center text-gray-300"
        xmlns="http://www.w3.org/2000/svg"
        width="14"
        height="14"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      ><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
      <div class="p-2 pl-1 text-gray-300">{to_time(@end_time)}</div>
    </div>
    """
  end

  defp to_time(timestamp) do
    timestamp
    |> MemexWeb.TimelineView.date_from_timestamp()
    |> DateTime.shift_zone!("Europe/Amsterdam")
    |> Calendar.strftime("%H:%M")
  end
end
