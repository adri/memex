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

    <div class="flex items-start justify-between gap-4">
      <div class="flex-grow w-24">
        <h3 class="dark:text-white">Timeline</h3>
        <%= for hit <- @last do %>
          <div class="flex-grow rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 my-2 shadow-md overflow-hidden dark:text-white">
            <p class="dark:text-white truncate"><%= hit["message_text"] %></p>
          </div>
        <% end %>

        <h3 class="dark:text-white">Links</h3>
        <%= for hit <- @links do %>
          <div class="rounded-md bg-white dark:bg-gray-900 hover:border-blue-100 transition-colors p-4 my-2 shadow-md overflow-hidden dark:text-white">
            <span class="dark:text-white truncate block"><%= hit["message_text"] %></span>
          </div>
        <% end %>
      </div>

      <div class="flex-none w-1/4 min-w-full">
        <div class="">
          <%= for {provider, count} <- @counts do %>
              <p class="dark:text-white"><%= provider %></p>
              <p class="dark:text-white"><%= count %></p>
          <% end %>
        </div>

        <div class="p-2">
          <h3 class="dark:text-white">Photos</h3>
          <div class="grid gap-4">
          <%= for hit <- @photos do %>
              <img class="object-cover h-20 w-20 rounded inline-block" width="60" height="60" src="<%= Routes.photo_path(MemexWeb.Endpoint, :image, hit["photo_file_path"]) %>" />
          <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
