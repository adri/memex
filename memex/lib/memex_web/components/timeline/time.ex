defmodule MemexWeb.Timeline.Time do
  @moduledoc false
  use Surface.Component

  prop(date, :datetime)

  def render(assigns) do
    ~F"""
    <div
      phx-click="filter-reset"
      phx-value-key="time"
      phx-value-value={"\"#{to_iso(@date)}\""}
      class="flex-none cursor-pointer self-center text-right text-gray-400 dark:text-gray-500 text-xs md:text-md -ml-12 md:-ml-32 w-12 md:w-32 pr-5"
    >
      {to_time(@date)}
    </div>
    """
  end

  defp to_time(date), do: Calendar.strftime(date, "%H:%M")
  defp to_iso(date), do: DateTime.to_iso8601(date)
end
