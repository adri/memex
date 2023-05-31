defmodule Memex.Importer do
  @moduledoc false
  import Memex.Connector

  alias Memex.Repo
  alias Memex.Schema.Document
  alias Memex.Schema.ImporterLog

  @max_records_per_batch 20_000
  @pubsub Memex.PubSub

  defmodule Sqlite do
    @moduledoc false
    defstruct [:location, :query, setup: [], connection_options: []]
  end

  defmodule Command do
    @moduledoc false
    defstruct [:command, :arguments]
  end

  defmodule Shell do
    @moduledoc false
    defstruct [:command]
  end

  defmodule JsonEndpoint do
    defstruct [:url, :headers]
  end

  defmodule JsonFile do
    @moduledoc false
    defstruct [:location, :compressed]
  end

  def parse_body(""), do: {:error, :no_data}
  def parse_body([]), do: {:error, :no_data}
  def parse_body(list), do: {:ok, Enum.map(list, &[body: &1])}

  def available_importers do
    with {:ok, list} <- :application.get_key(:memex, :modules) do
      list
      |> Enum.filter(&(&1 |> Module.split() |> Enum.take(2) == ~w|Memex Importers|))
      |> Enum.map(fn module ->
        {:module, module} = Code.ensure_loaded(module)
        module
      end)
      |> Enum.filter(&function_exported?(&1, :provider, 0))
      |> Map.new(fn module -> {module.provider(), module} end)
    end
  end

  def configured_importers do
    Repo.all(Memex.Schema.ImporterConfig)
  end

  def register_importers do
    existing_importers = Enum.map(configured_importers(), & &1.provider)

    available_importers()
    |> Enum.reject(fn {id, _importer} -> Enum.member?(existing_importers, id) end)
    |> Enum.reject(fn {_id, module} -> function_exported?(module, :required_config, 0) end)
    |> Enum.map(fn {id, importer} ->
      create_importer(
        id,
        importer.provider(),
        importer.provider(),
        importer.default_config(),
        %{}
      )
    end)
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

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, topic())
  end

  defp broadcast!(msg) do
    Phoenix.PubSub.broadcast!(@pubsub, topic(), {__MODULE__, msg})
  end

  defp topic, do: "importer:*"

  def insert(list) do
    with {:ok, documents} <- parse_body(list) do
      bulk_upsert_documents(documents)
    end
  end

  @doc """
  Fetches, transforms and stores documents from a given importer config.
  """
  def import(config) do
    {:ok, module} = get_module(config)

    if function_exported?(module, :fetch, 1) do
      do_import(config)
    else
      {:skipped, :fetch_not_supported}
    end
  end

  defp do_import(config) do
    {:ok, log} = Repo.insert(%ImporterLog{state: "running", log: "", config_id: config.id})
    broadcast!(log)

    try do
      with {:ok, module} <- get_module(config),
           {:ok, merged_config} <- merge_module_config(module, config),
           {:fetch, {:ok, result}} <- {:fetch, fetch(module, merged_config)},
           {:transform, {:ok, documents, invalid}} <-
             {:transform, transform(module, result, merged_config)},
           # todo: keep fetching until items show up that are already stored
           {:store, {:ok}} <- {:store, store(module, documents, log)} do
        update_log(log, "success", Kernel.inspect(invalid))

        {:ok, documents, invalid}
      else
        {step, error} ->
          update_log(log, "error", Kernel.inspect(error))
          {:error, step, error}
      end
    catch
      error, reason ->
        update_log(log, "error", Kernel.inspect(reason))

        IO.puts(:stderr, Exception.format(:error, reason, __STACKTRACE__))

        {:error, error, reason}
    end
  end

  def get_dirs_to_watch do
    configured_importers()
    |> Enum.map(fn config ->
      with {:ok, module} <- get_module(config),
           {:ok, merged_config} <- merge_module_config(module, config),
           :watcher <- merged_config["schedule"] do
        merged_config["location"]
      else
        _ -> false
      end
    end)
    |> Enum.filter(fn dir -> dir !== false end)
    |> Enum.filter(fn dir -> not is_nil(dir) end)
  end

  defp get_module(config) do
    case available_importers()[config.provider] do
      nil ->
        {:error, :no_importer_available}

      module ->
        {:ok, module}
    end
  end

  defp merge_module_config(module, config) do
    merged =
      module.default_config()
      |> Map.merge(config.config_overwrite)
      |> Map.merge(config.encrypted_secrets)

    {:ok, merged}
  end

  defp update_log(log, state, message) do
    log
    |> Ecto.Changeset.change(%{state: state, log: message})
    |> Repo.update!()
    |> broadcast!()
  end

  defp fetch(module, config) do
    case module.fetch(config) do
      %Sqlite{
        location: location,
        query: query,
        setup: setup,
        connection_options: connection_options
      } ->
        sqlite_json(location, query, [], setup, connection_options)

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

    documents = Enum.map(result, fn item -> Ecto.Changeset.cast(struct(module), item, fields) end)

    valid =
      documents
      |> Enum.filter(fn document -> document.valid? end)
      |> Enum.map(fn document -> document.changes end)

    invalid = Enum.filter(documents, fn document -> not document.valid? end)

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
