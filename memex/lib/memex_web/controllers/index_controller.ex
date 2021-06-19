defmodule MemexWeb.IndexController do
  use MemexWeb, :controller

  plug Plug.Parsers,
    parsers: [],
    pass: ["text/*"],
    body_reader: {}

  alias Memex.Schema.Document
  alias Memex.Repo

  @max_records_per_batch 20000

  def upsert_documents(conn, %{"index" => _index} = params) do
    with {:ok, documents} <- parse_body(params["_json"]),
         {:ok} <- bulk_upsert_documents(documents) do
      conn
      |> send_resp(200, "ok")
    else
      {:error, :no_data} -> send_resp(conn, 400, 'No content')
      {:error, error} -> send_resp(conn, 400, error)
    end
  end

  defp parse_body(""), do: {:error, :no_data}
  defp parse_body([]), do: {:error, :no_data}
  defp parse_body(body), do: {:ok, body |> Enum.map(&[body: &1])}

  defp bulk_upsert_documents(documents) do
    {current_batch, next_batch} = Enum.split(documents, @max_records_per_batch)

    Repo.insert_all(Document, current_batch,
      on_conflict: {:replace, [:body]},
      conflict_target: :id
    )

    case next_batch do
      [] -> {:ok}
      _ -> bulk_upsert_documents(next_batch)
    end
  end
end
