defmodule MemexWeb.Timeline.Card do
  use Surface.Component

  @doc "Middle section content the card"
  slot(content, required: true)

  @doc "Image to the left of the card"
  slot(media)

  @doc "Section on the right of the card"
  slot(right)

  def render(assigns) do
    ~F"""
    <div class="flex-grow rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 my-2 ml-2 shadow-md overflow-hidden dark:text-white">
      <div class="float-right"><#slot name="right" /></div>
      <div class="float-left"><#slot name="media" /></div>
      <#slot name="content" />
    </div>
    """
  end
end
