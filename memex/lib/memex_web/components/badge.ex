defmodule MemexWeb.Components.Badge do
  use Surface.Component

  prop click, :event
  prop values, :keyword, default: []
  prop class, :css_class

  slot default
  slot icon

  def render(assigns) do
    ~F"""
    <button
      :on-click={@click}
      :values={@values}
      class={
        "bg-blue-100 text-blue-800 text-xs font-medium inline-flex items-center px-2.5 py-0.5 rounded-md",
        @class
      }
    >
      <#slot {@icon} />
      <#slot />
    </button>
    """
  end
end
