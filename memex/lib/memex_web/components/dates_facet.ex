defmodule MemexWeb.DatesFacet do
  @moduledoc false
  use Surface.Component

  alias Phoenix.LiveView.JS

  @target "#search-input"

  prop(dates, :list)
  prop(max_count, :number)
  prop(loading, :boolean, default: false)

  def render(assigns) do
    assigns = update(assigns)

    ~F"""
    <div id="date-facet" class={"cursor-pointer relative", "opacity-50": @loading}>
      <div
        :for={{date, count} <- @dates}
        class="group text-xs hover:bg-gray-100 hover:dark:bg-gray-600"
        id={"facet-#{date}"}
        phx-click={filter_by_date(date)}
      >
        <span
          class="absolute opacity-0 group-hover:opacity-100 text-gray-500 dark:text-gray-100 leading-3"
          style="font-size: 8px; margin-top: -2px"
        >{date} ({count})</span>
        <button
          id={date}
          title={"#{date} (#{count})"}
          class="dark:bg-gray-700 bg-gray-300 group-hover:dark:bg-gray-500 group-hover:bg-gray-200 ml-auto block mb-px h-2 transition-all"
          style={"width: #{unless @max_count == 0 do
            round(max(1, 100 / @max_count * count))
          else
            1
          end}%;"}
        />
      </div>
    </div>
    """
  end

  defp filter_by_date(date) do
    %JS{}
    |> JS.dispatch("removeFilter", to: @target, detail: %{key: "time"})
    |> JS.dispatch("removeFilter", to: @target, detail: %{key: "month"})
    |> JS.dispatch("addFilter", to: @target, detail: %{key: "month", value: date})
    |> JS.dispatch("search", to: @target)
  end

  defp update(assigns) do
    assign(assigns, :max_count, max_count(assigns.dates))
  end

  defp max_count(dates) do
    dates
    |> Enum.max_by(fn {_date, count} -> count end, fn -> {"", 0} end)
    |> elem(1)
  end
end
