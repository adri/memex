defmodule MemexWeb.SearchBar do
  use Surface.Component

  prop(query, :string)

  def render(assigns) do
    ~F"""
    <div class="p-5 pt-0 font-san items-center justify-center">
      <header class="block fixed md:ml-4 text-black w-8/12 dark:text-white shadow-lg dark:bg-black bg-white rounded-xl">
        <div class="flex justify-center items-center flex-grow relative">
          <button class="flex items-center justify-center absolute left-0 top-5 rounded-l-xl px-4 text-black dark:text-white">
            <svg
              class="h-4 w-4 text-grey-dark"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
            >
              <path d="M16.32 14.9l5.39 5.4a1 1 0 0 1-1.42 1.4l-5.38-5.38a8 8 0 1 1 1.41-1.41zM10 16a6 6 0 1 0 0-12 6 6 0 0 0 0 12z" />
            </svg>
          </button>
          <form
            class="w-full relative"
            id="search-form"
            phx-change="search"
            phx-submit="search"
            phx-window-keydown="key-pressed"
            role="search"
            novalidate=""
          >
            <input
              autocapitalize="off"
              autocomplete="off"
              autofocus="true"
              class="transition-colors focus:ring-blue-900 focus:ring-2 z-1 w-full text-black dark:text-white bg-transparent pl-10 pr-2 py-4 rounded-xl border-0"
              id="search-input"
              maxlength="512"
              name="query"
              phx-debounce="10"
              phx-hook="ForceInputValue"
              placeholder="Search..."
              spellcheck="false"
              type="search"
              value={@query}
            />
          </form>
          <span class="absolute right-5 hidden sm:block text-gray-500 text-sm leading-5 py-0.5 px-1.5 border border-gray-700 rounded-md"><span class="sr-only">Press
            </span><kbd class="font-sans"><abbr title="Command" class="no-underline">⌘</abbr></kbd><span class="sr-only">
              and
            </span><kbd class="font-sans">K</kbd><span class="sr-only">
              to search</span></span>
        </div>
      </header>
    </div>
    """
  end
end
