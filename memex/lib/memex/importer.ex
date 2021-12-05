defmodule Memex.Importer do
  @max_records_per_batch 20000

  alias Memex.Repo
  alias Memex.Schema.Document

  def parse_body(""), do: {:error, :no_data}
  def parse_body([]), do: {:error, :no_data}
  def parse_body(list), do: {:ok, list |> Enum.map(&[body: &1])}

  def insert(list) do
    with {:ok, documents} <- parse_body(list) do
      bulk_upsert_documents(documents)
    end
  end

  def bulk_upsert_documents(documents) do
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

  def config(provider_id) do
    Repo.get(Memex.Schema.ImporterConfig, provider_id).config
  end
end
