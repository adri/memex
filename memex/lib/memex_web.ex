defmodule MemexWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use MemexWeb, :controller
      use MemexWeb, :view
      use MemexWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths do
    ~w(assets fonts images favicon.ico robots.txt)
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: MemexWeb.Layouts]

      import Plug.Conn
      import MemexWeb.Gettext
      alias MemexWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

  # def view do
  #   quote do
  #     use Phoenix.View,
  #       root: "lib/memex_web/templates",
  #       namespace: MemexWeb

  #     # Import convenience functions from controllers
  #     import Phoenix.Controller,
  #       only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

  #     # Include shared imports and aliases for views
  #     unquote(view_helpers())
  #   end
  # end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MemexWeb.Layouts, :app}

      unquote(html_helpers())
      unquote(liveview_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      unquote(html_helpers())
    end
  end

  def surface_live_view do
    quote do
      use Surface.LiveView,
        layout: {MemexWeb.Layouts, :app}

      unquote(html_helpers())
      unquote(liveview_helpers())
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

  def html do
    quote do
      use Phoenix.Component
      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import MemexWeb.CoreComponents
      import MemexWeb.Gettext
      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      alias MemexWeb.Router.Helpers, as: Routes

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: MemexWeb.Endpoint,
        router: MemexWeb.Router,
        statics: MemexWeb.static_paths()
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
        {:noreply, assign(socket, key, result)}
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
