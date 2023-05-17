defmodule MemexWeb.Sidebars.GenericLive do
  use MemexWeb, :surface_live_view

  alias Memex.Search.Postgres
  alias Memex.Search.Query
  alias MemexWeb.Timeline

  def mount(params, session, socket) do
    {:ok, doc} = Postgres.find(session["id"] || params["id"])

    within =
      Postgres.query(%Query{
        select: :hits_with_highlights,
        limit: 3,
        filters: %{"created_at_within" => DateTime.from_unix!(doc["timestamp_unix"])}
      })

    {
      :ok,
      socket
      |> assign(doc: doc, within: within)
      #  |> async_query(:items, [], %Query{
      #    limit: 20,
      #    filters: %{"created_at_betweeenc" => doc["timestamp_utc"]},
      #    order_by: ["created_at_desc"]
      #  })
    }
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="text-white">Generic</div>
    <Timeline :if={@within} items={@within ++ [@doc]} />
    """
  end
end
