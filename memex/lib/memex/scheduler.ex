defmodule Memex.Scheduler do
  @moduledoc false
  use GenServer

  alias Memex.Importer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_args) do
    schedule()
    {:ok, watcher_pid} = register_watcher()
    # Importer.register_importers()

    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info(:run, state) do
    run()
    schedule()

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    IO.inspect({watcher_pid, {path, events}}, label: "55")

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    IO.inspect({watcher_pid, "stop"}, label: "55")
    {:noreply, state}
  end

  defp run do
    IO.inspect("Running importer", label: "scheduler")

    Enum.map(Importer.configured_importers(), fn importer -> Importer.import(importer) end)
    # todo:
    # - loop all importers
    # - loop all documents of an importer
    #   - get schedule from fetch config
    #   - if it's :watcher, start a watcher that runs the import
    #   - if it's :interval, 10, :minutes schedule a job
    #   - (future) if it's :auto, get schedule a job based on history
  end

  defp register_watcher do
    IO.inspect("Watching paths")
    IO.inspect(Importer.get_dirs_to_watch())
    {:ok, pid} = FileSystem.start_link(dirs: [Importer.get_dirs_to_watch()])
    FileSystem.subscribe(pid)

    {:ok, pid}
  end

  defp schedule do
    Process.send_after(self(), :run, 1 * 60 * 60 * 1000)
  end
end
