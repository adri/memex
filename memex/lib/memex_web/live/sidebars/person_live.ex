defmodule MemexWeb.Sidebars.PersonLive do
  use MemexWeb, :live_view

  alias Memex.Search.Postgres, as: Search
  alias Memex.Search.Query

  @impl true
  def mount(params, session, socket) do
    hit = session["hit"]
    name = hit["name"] || params["name"]

    {:ok,
     socket
     |> assign(name: name, hit: hit, last: [], counts: %{})
     |> async_query(:last, [], %Query{
       filters: %{"person_name" => name},
       order_by: ["created_at_desc"],
       limit: 10
     })
     |> async_query(:links, [], %Query{
       query: "http",
       filters: %{"person_name" => name},
       order_by: ["created_at_desc"],
       limit: 10
     })
     |> async_query(:photos, [], %Query{
       filters: %{"provider" => "Photos", "person_name" => name},
       order_by: ["created_at_desc"],
       limit: 3
     })
     |> assign_async(fn -> {:counts, Search.count_by_name(name)} end)}
  end

  @impl true
  def render(assigns) do
    assigns |> IO.inspect(label: "36")

    ~L"""
    <div class="flex place-items-start justify-between">
      <h2 class="text-lg flex-grow dark:text-white leading-7"><%= @name %></h2>
    </div>

    <div class="flex space-x-4">
      <%= for {provider, count} <- @counts do %>
        <div class="flex-1 rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 my-2 shadow-md overflow-hidden dark:text-white">
          <span class="float-right rounded-full bg-gray-700 px-2 py-1 text-xs"><%= MemexWeb.TimelineView.number_short(count) %></span>
          <p class="dark:text-white truncate"><%= provider %></p>
          <%= if provider === "Photos" do %>
            <div class="flex space-x-2 mt-2">
            <%= for hit <- @photos do %>
                <img class="object-cover w-10 h-10 rounded inline-block" width="60" height="60" src="<%= Routes.photo_path(MemexWeb.Endpoint, :image, hit["photo_file_path"]) %>" />
            <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>

    <div class="flex flex-col justify-between gap-4">
        <h3 class="dark:text-white">Timeline</h3>
        <%= for hit <- @last do %>
          <div class="rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 shadow-md overflow-hidden dark:text-white">
            <p class="dark:text-white truncate"><%= hit["message_text"] %></p>
          </div>
        <% end %>

        <h3 class="dark:text-white">Links</h3>
        <%= for hit <- @links do %>
          <div class="rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 shadow-md overflow-hidden dark:text-white">
            <span class="dark:text-white truncate block"><%= hit["message_text"] %></span>
          </div>
        <% end %>
    </div>
    """
  end
end
