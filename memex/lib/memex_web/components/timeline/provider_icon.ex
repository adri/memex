defmodule MemexWeb.Timeline.ProviderIcon do
  use Surface.Component

  prop(provider, :string)

  def render(assigns) do
    ~F"""
    <figure
      :if={is_nil(icon(@provider))}
      class="flex-none self-center inline-block rounded-full w-2 h-2 -ml-2 dark:bg-gray-400"
    />
    <div :if={icon(@provider)} class="flex-none self-center inline-block w-6 h-6 -ml-4">
      <img src={"#{icon(@provider)}"}>
    </div>
    """
  end

  def icon(provider), do: MemexWeb.TimelineView.icon_by_provider(provider)
end
