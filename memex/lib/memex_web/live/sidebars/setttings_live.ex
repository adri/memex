defmodule MemexWeb.Sidebars.SettingsLive do
  use MemexWeb, :surface_live_view

  alias Memex.Search.Postgres
  alias Memex.Search.Query
  alias MemexWeb.Timeline
  alias MemexWeb.Map
  alias MemexWeb.Timeline.Card
  alias MemexWeb.TimeDuration

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
