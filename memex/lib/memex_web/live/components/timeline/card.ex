defmodule MemexWeb.Timeline.Card do
  use Surface.Component

  prop class, :css_class

  @doc "Middle section content the card"
  slot content, required: true

  @doc "Image to the left of the card"
  slot media

  @doc "Section on the right of the card"
  slot right

  def render(assigns) do
    ~F"""
    <div class={"#{@class} flex-grow rounded-md bg-white dark:bg-gray-900 hover:shadow-lg hover:pt-3 hover:pb-5 hover:ring-gray-700 hover:ring-2 cursor-pointer transition-all p-4 my-2 shadow-md overflow-hidden dark:text-white"}>
      <div class="float-right"><#slot name="right" /></div>
      <div class="float-left"><#slot name="media" /></div>
      <#slot name="content" />
    </div>
    """
  end
end
