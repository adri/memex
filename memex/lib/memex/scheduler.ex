defmodule Memex.Scheduler do
  alias Memex.Importer
  alias Memex.Importers.GithubImporter
  alias Memex.Importers.SafariImporter
  alias Memex.Importers.Notes

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
    GithubImporter.import()

    [SafariImporter.Document, Memex.Importers.FishShell.Document, Notes]
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
