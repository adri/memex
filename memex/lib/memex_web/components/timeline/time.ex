defmodule MemexWeb.Timeline.Time do
  @moduledoc false
  use Surface.Component

  alias Phoenix.LiveView.JS

  @target "#search-input"

  prop(date, :datetime)

  def render(assigns) do
    ~F"""
    <div
      phx-click={filter_by_time(@date)}
      class="flex-none cursor-pointer self-center text-right text-gray-400 dark:text-gray-500 text-xs md:text-md -ml-12 md:-ml-32 w-12 md:w-32 pr-5"
    >
      {to_time(@date)}
    </div>
    """
  end

  defp filter_by_time(date) do
    %JS{}
    |> JS.dispatch("resetFilters", to: @target)
    |> JS.dispatch("addFilter", to: @target, detail: %{key: "time", value: to_iso(date)})
    |> JS.dispatch("search", to: @target)
  end

  defp to_time(date), do: Calendar.strftime(date, "%H:%M")
  defp to_iso(date), do: DateTime.to_iso8601(date)
end
