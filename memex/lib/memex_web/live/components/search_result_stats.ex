defmodule MemexWeb.SearchResultStats do
  use Surface.Component

  prop(totalHits, :number)
  prop(processingTimeMs, :number)

  def render(assigns) do
    ~F"""
    <div :if={@totalHits != nil and @processingTimeMs != nil}
      class="text-xs dark:text-gray-600 text-gray-400 ml-12 md:ml-20 mt-1">
      <div class="flex w-auto items-start">
        <div class="flex-none self-stretch border-l border-r dark:border-gray-800 border-gray-200 bg-gray-400 dark:bg-gray-700 w-2 -ml-1"></div>

        <div class="pl-3">
          <span class="pt-4 inline-block">Found {@totalHits} results in {@processingTimeMs} ms</span>
        </div>
      </div>
    </div>
    """
  end
end
