defmodule MemexWeb.Sidebars.SettingsLive do
  use MemexWeb, :surface_live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="text-white">Settings</div>
    """
  end
end
