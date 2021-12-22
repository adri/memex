defmodule MemexWeb.Sidebars.SettingsLive do
  use MemexWeb, :surface_live_view
  alias Memex.Search.Sidebars
  alias MemexWeb.Components.Badge
  alias MemexWeb.Components.Text
  alias MemexWeb.Components.Icon
  alias MemexWeb.Components.Forms.ToggleSwitch
  alias MemexWeb.Timeline.Card

  def mount(params, session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <Text.H1>Settings</Text.H1>
      <Text.SubtTitle>Configure integrations and other settings.</Text.SubtTitle>

      <Text.H2>Integrations</Text.H2>
      <Badge class="text-white bg-gray-900 float-right" click="open-sidebar" values={type: "settings"}>
        <:icon><Icon.Plus /></:icon> Add new
      </Badge>
      <Text.SubtTitle>Configure integrations and what can be searched for.</Text.SubtTitle>

      <Card>
        <:media><ToggleSwitch id="github" click="toggle_importer" value={importer: :github} /></:media>
        <:content>
          Github Events
          <p class="text-xs dark:text-gray-500">Last import: 2 hours ago</p>
        </:content>
        <:right>
          <Badge click="open-sidebar" values={type: "importer"}><:icon><Icon.Settings /></:icon>Settings</Badge>
        </:right>
      </Card>

      <Card>
        <:media><ToggleSwitch id="safari" click="toggle_importer" value={importer: :safari} /></:media>
        <:content>Safari <p class="text-xs dark:text-gray-500">Last import: 2 hours ago</p></:content>
      </Card>

      <Card>
        <:media><ToggleSwitch id="photos" click="toggle_importer" value={importer: :photos} /></:media>
        <:content>Photos <p class="text-xs dark:text-gray-500">Last import: 2 hours ago</p></:content>
      </Card>
    </div>
    """
  end


  @impl true
  def handle_event("open-sidebar", sidebar, socket) do
    Sidebars.broadcast_open(sidebar)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_importer", _, socket) do
    {:noreply, socket}
  end
end
