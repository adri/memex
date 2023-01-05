defmodule Memex.Importer do
  @max_records_per_batch 20000
  @pubsub Memex.PubSub

  alias Memex.Repo
  alias Memex.Schema.Document
  alias Memex.Schema.ImporterLog
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
      |> Enum.map(fn module ->
        {:module, module} = Code.ensure_loaded(module)
        module
      end)
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

  def subscribe() do
    Phoenix.PubSub.subscribe(@pubsub, topic())
  end

  defp broadcast!(msg) do
    Phoenix.PubSub.broadcast!(@pubsub, topic(), {__MODULE__, msg})
  end

  defp topic(), do: "importer:*"

  def insert(list) do
    with {:ok, documents} <- parse_body(list) do
      bulk_upsert_documents(documents)
    end
  end

  def import(config) do
    {:ok, log} = Repo.insert(%ImporterLog{state: "running", log: "", config_id: config.id})
    broadcast!(log)
    dynamic_config = Map.merge(config.config_overwrite, config.encrypted_secrets)

    with {:ok, module} <- get_module(config),
         merged_config <- module.default_config(dynamic_config),
         {:fetch, {:ok, result}} <- {:fetch, fetch(module, merged_config)},
         {:transform, {:ok, documents, invalid}} <-
           {:transform, transform(module, result, merged_config)},
         # todo: keep fetching until items show up that are already stored
         {:store, {:ok}} <- {:store, store(module, documents, log)} do
      log
      |> Ecto.Changeset.change(%{state: "success", log: Kernel.inspect(invalid)})
      |> Repo.update!()
      |> broadcast!()

      {:ok, documents, invalid}
    else
      {step, error} ->
        log
        |> Ecto.Changeset.change(%{state: "error", log: Kernel.inspect(error)})
        |> Repo.update!()
        |> broadcast!()

        {:error, step, error}
    end
  end

  defp get_module(config) do
    case available_importers()[config.provider] do
      nil ->
        {:error, :no_importer_available}

      module ->
        {:ok, module}
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

  defp store(_module, documents, log) do
    documents
    |> Enum.map(fn document -> [body: document, importer_log_id: log.id] end)
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
