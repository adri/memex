defmodule MemexWeb.Components.Forms.ToggleSwitch do
  @moduledoc false
  use Surface.Component

  prop id, :string
  prop click, :event
  prop checked, :boolean, default: false
  prop values, :keyword, default: []

  def render(assigns) do
    ~F"""
    <div class="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
      <input
        type="checkbox"
        :on-click={@click}
        :values={@values}
        checked={@checked}
        name={@id}
        id={@id}
        class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white dark:bg-gray-600 border-4 dark:border-gray-500 appearance-none cursor-pointer checked:right-0 checked:border-green-400 checked:bg-green-100"
      />
      <label
        for={@id}
        class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 dark:bg-gray-800 cursor-pointer"
      />
    </div>
    """
  end
end
