defmodule MemexWeb.Timeline.VerticalLine do
  use Surface.Component

  prop(class, :string, default: "")

  def render(assigns) do
    ~F"""
    <div class={"flex-none self-stretch border-l border-r dark:border-gray-800 border-gray-200 w-2 -ml-1 #{@class}"}></div>
    """
  end
end
