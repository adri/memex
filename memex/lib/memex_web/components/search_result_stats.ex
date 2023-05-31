defmodule MemexWeb.SearchResultStats do
  @moduledoc false
  use Surface.Component

  prop(total_hits, :number)

  def render(assigns) do
    ~F"""
    <div class="text-xs dark:text-gray-600 text-gray-400 ml-12 md:ml-20 mt-1">
      <div class="flex w-auto items-start">
        <div class="flex-none self-stretch border-l border-r dark:border-gray-800 border-gray-200 bg-gray-400 dark:bg-gray-700 w-2 -ml-1" />

        <div class="pl-3">
          <span class="pt-4 inline-block">
            {#if @total_hits != nil}
              Found {MemexWeb.TimelineView.number_short(@total_hits)} results
            {#else}
              &nbsp;
            {/if}
          </span>
        </div>
      </div>
    </div>
    """
  end
end
