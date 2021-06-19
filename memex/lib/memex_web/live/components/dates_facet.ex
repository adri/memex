defmodule MemexWeb.DatesFacet do
  use Surface.Component

  prop(dates, :map)

  def render(assigns) do
    ~H"""
    <div :if={{ @dates }} id="date-facet" class="cursor-pointer relative">
      <div :for={{ {date, count} <- Enum.sort(@dates, &(&1 > &2)) }} class="group hover:dark:bg-gray-600 hover:bg-gray-100 text-xs"
        phx-click="filter-date"
        phx-value-key="month"
        phx-value-value={{ date }}>
        <span class="absolute opacity-0 group-hover:opacity-100 text-gray-500 dark:text-gray-100 leading-3"
          style="font-size: 8px; margin-top: -2px">{{ date }} ({{ count }})</span>
        <button
          id={{ date }}
          title="{{ date }} ({{ count }})"
          class="dark:bg-gray-700 bg-gray-300 group-hover:dark:bg-gray-500 group-hover:bg-gray-200 ml-auto block mb-px h-2"
          style="width: {{ unless max_count(@dates) == 0 do round(max(1, (100 / max_count(@dates)) * count )) else 1 end }}%;"></button>
      </div>
    </div>
    """
  end

  defp max_count(dates) do
    try do
      Enum.max(Map.values(dates))
    rescue
      Enum.EmptyError -> 0
    end
  end
end
