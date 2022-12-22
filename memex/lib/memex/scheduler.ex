defmodule Memex.Scheduler do
  alias Memex.Importer
  alias Memex.Importers.GithubImporter

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:run, state) do
    run()
    schedule()
    {:noreply, state}
  end

  defp run() do
    IO.inspect("Running importer", label: "scheduler")

    [
      Memex.Importers.AppleMessages,
      Memex.Importers.ApplePhotos,
      Memex.Importers.ApplePodcasts,
      Memex.Importers.Arc,
      Memex.Importers.FishShell,
      Memex.Importers.Github,
      Memex.Importers.Notes,
      Memex.Importers.Safari
    ]
    # todo:
    # - loop all importers
    # - loop all documents of an importer
    #   - get schedule from fetch config
    #   - if it's :watcher, start a watcher that runs the import
    #   - if it's :interval, 10, :minutes schedule a job
    #   - (future) if it's :auto, get schedule a job based on history
    |> Enum.map(fn importer -> Importer.import(importer) end)
  end

  defp schedule() do
    Process.send_after(self(), :run, 1 * 60 * 60 * 1000)
  end
end
