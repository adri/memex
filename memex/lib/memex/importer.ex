defmodule Memex.Importer do
  @max_records_per_batch 20000

  alias Memex.Repo
  alias Memex.Schema.Document
  import Memex.Connector

  defmodule Sqlite do
    defstruct [:location, :query]
  end

  defmodule Command do
    defstruct [:command, :arguments]
  end

  defmodule Shell do
    defstruct [:command]
  end

  def parse_body(""), do: {:error, :no_data}
  def parse_body([]), do: {:error, :no_data}
  def parse_body(list), do: {:ok, list |> Enum.map(&[body: &1])}

  def insert(list) do
    with {:ok, documents} <- parse_body(list) do
      bulk_upsert_documents(documents)
    end
  end

  def import(module) do
    with config <- module.default_config(),
         # todo: get dynamic config via config(provider)
         {:ok, result} <- fetch(module, config),
         {:ok, documents, _invalid} <- transform(module, result),
         {:ok} <- store(module, documents) do
      {:ok}
    end
  end

  defp fetch(module, config) do
    case module.fetch(config) do
      %Sqlite{location: location, query: query} ->
        sqlite_json(location, query)

      %Command{command: command, arguments: args} ->
        cmd(command, args)

      %Shell{command: command} ->
        shell(command)

      _ ->
        {:error, :unkown_fetch_type}
    end
  end

  defp transform(module, result) do
    fields = module.__schema__(:fields)

    result =
      if function_exported?(module, :transform, 1) do
        module.transform(result)
      else
        result
      end

    documents =
      result
      |> Enum.map(fn item -> Ecto.Changeset.cast(struct(module), item, fields) end)

    valid =
      documents
      |> Enum.filter(fn document -> document.valid? end)
      |> Enum.map(fn document -> document.changes end)

    invalid =
      documents
      |> Enum.filter(fn document -> not document.valid? end)

    {:ok, valid, invalid}
  end

  defp store(module, documents) do
    documents
    # |> IO.inspect(label: "74")
    |> Enum.map(fn document -> [body: document] end)
    |> bulk_upsert_documents()

    {:ok}
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
