defmodule MemexWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use MemexWeb, :controller
      use MemexWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MemexWeb

      import Plug.Conn
      import MemexWeb.Gettext
      alias MemexWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/memex_web/templates",
        namespace: MemexWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MemexWeb.LayoutView, "live.html"}

      unquote(view_helpers())
      unquote(liveview_helpers())
    end
  end

  def surface_live_view do
    quote do
      use Surface.LiveView,
        layout: {MemexWeb.LayoutView, "live.html"}

      unquote(view_helpers())
      unquote(liveview_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MemexWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import MemexWeb.ErrorHelpers
      import MemexWeb.Gettext
      alias MemexWeb.Router.Helpers, as: Routes
    end
  end

  defp liveview_helpers do
    quote do
      defp async_query(socket, key, default, query) do
        socket
        |> assign_default_if_not_set(key, default)
        |> assign_async(key, fn -> {key, Memex.Search.Postgres.query(query)} end)
      end

      defp assign_default_if_not_set(socket, key, default) do
        case socket.assigns[key] do
          nil -> assign(socket, key, default)
          _ -> socket
        end
      end

      defp assign_async(socket, key, callback) do
        cancel_current_assign(socket.assigns["#{key}_pid"])

        pid = self()
        child_pid = spawn(fn -> send(pid, {:async_assign, callback.()}) end)

        socket
        |> assign("#{key}_pid", child_pid)
      end

      defp assign_async_loading?(socket, key) do
        socket.assigns["#{key}_pid"] != nil
      end

      defp cancel_current_assign(pid), do: pid && Process.exit(pid, :kill)

      @impl true
      def handle_info({:async_assign, {key, result}}, socket) do
        {:noreply, assign(socket, Keyword.put([], key, result))}
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
