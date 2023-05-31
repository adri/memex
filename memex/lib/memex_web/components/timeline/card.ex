defmodule MemexWeb.Timeline.Card do
  @moduledoc false
  use Surface.Component

  prop class, :css_class
  prop selected, :boolean, default: false

  @doc "Middle section content the card"
  slot content, required: true

  @doc "Image to the left of the card"
  slot media

  @doc "Section on the right of the card"
  slot right

  def render(assigns) do
    ~F"""
    <div class={
      @class,
      "flex-grow rounded-md bg-white dark:bg-gray-900 hover:shadow-lg hover:pt-3 hover:pb-5 hover:ring-gray-700 hover:ring-2 cursor-pointer transition-all p-4 my-2 shadow-md overflow-hidden dark:text-white",
      "shadow-lg pt-3 pb-5 ring-gray-700 ring-2": @selected
    }>
      <div class="float-right"><#slot {@right} /></div>
      <div class="float-left"><#slot {@media} /></div>
      <#slot {@content} />
    </div>
    """
  end
end
