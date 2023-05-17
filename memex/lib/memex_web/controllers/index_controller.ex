defmodule MemexWeb.IndexController do
  use MemexWeb, :controller

  plug Plug.Parsers,
    parsers: [],
    pass: ["text/*"],
    body_reader: {}

  alias Memex.Importer

  def upsert_documents(conn, %{"index" => _index} = params) do
    with {:ok, documents} <- Importer.parse_body(params["_json"]),
         {:ok} <- Importer.bulk_upsert_documents(documents) do
      conn
      |> send_resp(200, "ok")
    else
      {:error, :no_data} -> send_resp(conn, 400, 'No content')
      {:error, error} -> send_resp(conn, 400, error)
    end
  end
end
