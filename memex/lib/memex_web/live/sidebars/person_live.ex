defmodule MemexWeb.Sidebars.PersonLive do
  @moduledoc false
  use MemexWeb, :surface_live_view

  alias Memex.Search.Query
  alias MemexWeb.Timeline

  @impl true
  def mount(params, session, socket) do
    hit = session["hit"]
    name = hit["name"] || params["name"]

    {:ok,
     socket
     |> assign(name: name, hit: hit, last: [])
     |> async_query(:last, [], %Query{
       filters: [%{"type" =>"Equals", "key" => "person_name", "value" => name}],
       order_by: ["created_at_desc"],
       limit: 10
     })
     |> async_query(:links, [], %Query{
       filters: [
         %{"type" =>"Prefix", "value" => "http"},
         %{"type" =>"Equals", "key" => "person_name", "value" => name}
       ],
       order_by: ["created_at_desc"],
       limit: 10
     })
     |> async_query(:photos, [], %Query{
       filters: [
         %{"type" =>"Equals", "key" => "provider","value" => "Photos"},
         %{"type" =>"Equals", "key" => "person_name", "value" => name}
       ],
       order_by: ["created_at_desc"],
       limit: 3
     })
     |> async_query(:counts, [], %Query{
       select: [facet: "provider"],
       filters: [%{"type" =>"Equals", "key" => "person_name", "value" => name}],
     })
    }
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="flex place-items-start justify-between">
      <h2 class="text-lg flex-grow dark:text-white leading-7">{@name}</h2>
    </div>

    <div class="flex space-x-4">
        <div :for={{provider, count} <- @counts} class="flex-1 rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 my-2 shadow-md overflow-hidden dark:text-white">
          <span class="float-right rounded-full bg-gray-700 px-2 py-1 text-xs">{MemexWeb.TimelineView.number_short(count)}</span>
          <p class="dark:text-white truncate">{provider}</p>
          <div :if={provider === "Photos"} class="flex space-x-2 mt-2">
            <img :for={hit <- @photos} class="object-cover w-10 h-10 rounded inline-block" width="60" height="60" src="<%= Routes.photo_path(MemexWeb.Endpoint, :image, hit["photo_file_path"] || "") %>" />
          </div>
        </div>
    </div>

    <div class="flex flex-col justify-between gap-4">
        <h3 class="dark:text-white">Latest Timeline</h3>
        <Timeline
          items={@last}
          class="ml-12 md:ml-20"
        />
        <h3  class="dark:text-white">Links</h3>
        <div :for={hit <- @links} class="rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 shadow-md overflow-hidden dark:text-white">
          <span class="dark:text-white truncate block">{hit["message_text"]}</span>
        </div>
    </div>
    """
  end
end
