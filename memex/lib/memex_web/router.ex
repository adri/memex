defmodule MemexWeb.Router do
  use MemexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MemexWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MemexWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/photos/:path", PhotoController, :image
    get "/https_proxy/", PhotoController, :https_proxy
    get "/arc/geopoints", ArcController, :geopoint
    get "/arc/gpx", ArcController, :gpx
    get "/arc/geojson", ArcController, :geojson
    get "/alfred/search", AlfredController, :search
  end

  scope "/sidebar", MemexWeb do
    pipe_through :browser
    live "/activity", Sidebars.ActivityLive, :index
    live "/person", Sidebars.PersonLive, :index
    live "/settings", Sidebars.SettingsLive, :index
    live "/generic", Sidebars.GenericLive, :index
  end

  # Other scopes may use custom stacks.
  scope "/", MemexWeb do
    pipe_through :api
    post "/indexes/:index/documents", IndexController, :upsert_documents
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MemexWeb.Telemetry
    end
  end
end
