defmodule MemexWeb.Timeline.Time do
  use Surface.Component

  prop(date, :date)

  def render(assigns) do
    ~H"""
    <div class="flex-none self-center text-right text-gray-400 dark:text-gray-500 text-xs md:text-md -ml-12 md:-ml-32 w-12 md:w-32 pr-5">
      {{ to_time(@date) }}
    </div>
    """
  end

  defp to_time(date), do: Calendar.strftime(date, "%H:%M")
end
