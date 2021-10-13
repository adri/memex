defmodule Memex.Scheduler do
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
    GithubImporter.import()
  end

  defp schedule() do
    Process.send_after(self(), :run, 1 * 60 * 60 * 1000)
  end
end
