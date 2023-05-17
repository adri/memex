defmodule MemexWeb.Router do
  use MemexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MemexWeb.Layouts, :root}
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
end
