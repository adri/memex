defmodule MemexWeb.Timeline.DateBorder do
  use Surface.Component

  prop(date, :datetime, required: true)
  prop(days_between, :number, required: true)

  def render(assigns) do
    ~F"""
    <div class="text-base font-medium text-gray-500 p-3 dark:text-gray-500">
      <span>{format(@date)}</span>

      <span class="hidden md:inline-block text-xs transition-opacity opacity-0 group-hover:opacity-100">
        {days_between_to_text(@days_between)}
      </span>
    </div>
    """
  end

  defp format(date) do
    Calendar.strftime(date, "%A, %d %B %Y")
  end

  defp days_between_to_text(days_between) do
    case days_between do
      0 -> ""
      1 -> "1 day before"
      d when d <= 31 -> "#{d} days before"
      d when d <= 31 * 12 -> "#{round(d / 31)} months before"
      d -> "#{d / 365} years before"
    end
  end
end
