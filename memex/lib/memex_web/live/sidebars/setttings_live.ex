defmodule MemexWeb.Sidebars.SettingsLive do
  use MemexWeb, :surface_live_view
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
      <Text.SubtTitle>
        Configure importers and other settings.
      </Text.SubtTitle>

      <Text.H2>Importers</Text.H2>
      <Badge class="text-white bg-gray-900" click="open-sidebar" values={type: "settings"}>
        <:icon><Icon.Plus /></:icon>
        Add new
      </Badge>

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
        <:content>Safari</:content>
      </Card>

      <Card>
        <:media><ToggleSwitch id="photos" click="toggle_importer" value={importer: :photos} /></:media>
        <:content>Photos</:content>
      </Card>
    </div>
    """
  end

  def handle_event("toggle_importer", _, socket) do
    {:noreply, socket}
  end
end
