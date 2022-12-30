defmodule Memex.Importers.Notes do
  alias Memex.Importer

  use Ecto.Schema
  @primary_key false
  schema "document" do
    field :provider, :string
    field :verb, :string
    field :id, :string
    field :date_month, :string
    field :timestamp_utc, :string
    field :timestamp_unix, :integer
    field :commit_sha, :string
    field :commit_diff, :string
  end

  def provider(), do: "git-notes"

  def default_config() do
    %{
      schedule: :watcher
    }
  end

  def fetch(_config) do
    %Importer.Shell{
      command: """
      cd #{File.cwd!()}/../data/notes
      git fetch -q && git reset -q --hard origin/master && \
        git log -n6 --pretty=format:'<-SNIP->%H-;-%at-;-%B-;-' \
        --patch \
        --no-color \
        --no-ext-diff \
        --unified=0
      """
    }
  end

  def transform(result) do
    result
    |> String.split("<-SNIP->")
    |> Enum.map(&String.split(&1, "-;-"))
    |> Enum.filter(&(&1 != [""]))
    |> Enum.map(fn [sha1, timestamp_unix, _, diff] ->
      timestamp = DateTime.from_unix!(String.to_integer(timestamp_unix))

      %{
        id: "git-#{sha1}",
        verb: "committed",
        provider: provider(),
        timestamp_unix: String.to_integer(timestamp_unix),
        timestamp_utc: Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S"),
        date_month: Calendar.strftime(timestamp, "%Y-%m"),
        commit_sha: sha1,
        commit_diff: String.replace(diff, "\\\n\\\\ No newline at end of file", "")
      }
    end)
  end

  defmodule TimeLineItem do
    use Surface.Component

    prop doc, :map, required: true
    prop highlighted, :map

    def render(assigns) do
      ~F"""
      <div />
      """
    end
  end
end
