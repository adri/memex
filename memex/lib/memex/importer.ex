defmodule Memex.Importer do
  @max_records_per_batch 20000

  alias Memex.Repo
  alias Memex.Schema.Document
  import Memex.Connector

  defmodule Sqlite do
    defstruct [:location, :query, setup: []]
  end

  defmodule Command do
    defstruct [:command, :arguments]
  end

  defmodule Shell do
    defstruct [:command]
  end

  defmodule JsonEndpoint do
    defstruct [:url, :headers]
  end

  defmodule JsonFile do
    defstruct [:location, :compressed]
  end

  def parse_body(""), do: {:error, :no_data}
  def parse_body([]), do: {:error, :no_data}
  def parse_body(list), do: {:ok, list |> Enum.map(&[body: &1])}

  def available_importers() do
    with {:ok, list} <- :application.get_key(:memex, :modules) do
      list
      |> Enum.filter(&(&1 |> Module.split() |> Enum.take(2) == ~w|Memex Importers|))
      |> Enum.filter(&(&1 |> function_exported?(:provider, 0)))
      |> Enum.map(fn module -> {module.provider(), module} end)
      |> Enum.into(%{})
    end
  end

  def configured_importers() do
    Repo.all(Memex.Schema.ImporterConfig)
  end

  def create_importer(name, provider, display_name, encrypted_secrets, config_overwrite) do
    Repo.insert(%Memex.Schema.ImporterConfig{
      id: name,
      provider: provider,
      display_name: display_name,
      encrypted_secrets: encrypted_secrets,
      config_overwrite: config_overwrite
    })
  end

  def insert(list) do
    with {:ok, documents} <- parse_body(list) do
      bulk_upsert_documents(documents)
    end
  end

  def import(module) do
    with config <- module.default_config(),
         # todo: get dynamic config via config(provider)
         {:ok, result} <- fetch(module, config),
         {:ok, documents, invalid} <- transform(module, result, config),
         # todo: keep fetching until items show up that are already stored
         {:ok} <- store(module, documents) do
      {:ok, documents, invalid}
    end
  end

  defp fetch(module, config) do
    case module.fetch(config) do
      %Sqlite{location: location, query: query, setup: setup} ->
        sqlite_json(location, query, [], setup)

      %Command{command: command, arguments: args} ->
        cmd(command, args)

      %Shell{command: command} ->
        shell(command)

      %JsonEndpoint{url: url, headers: headers} ->
        response = Tesla.get!(url, headers: headers)
        {:ok, Jason.decode!(response.body)}

      %JsonFile{location: location, compressed: compressed} ->
        json_file(location, compressed)

      _ ->
        {:error, :unkown_fetch_type}
    end
  end

  defp transform(module, result, config) do
    fields = module.__schema__(:fields)

    result =
      if function_exported?(module, :transform, 1) do
        module.transform(result)
      else
        result
      end

    result =
      if function_exported?(module, :transform, 2) do
        module.transform(result, config)
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

  defp store(_module, documents) do
    documents
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

  def config(id) do
    Repo.get(Memex.Schema.ImporterConfig, id).config
  end
end
