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

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <div :for={patch <- parse_patch(@item["commit_diff"])}>
        <a
          href={"obsidian://open?#{URI.encode_query(%{"vault" => "Wiki_Synced", "file" => MemexWeb.TimelineView.nl2br(patch.from)})}"}
          target="_blank"
          class="text-xs text-gray-400 dark:text-gray-400"
        >
          {raw(MemexWeb.TimelineView.highlight_line_text(patch.from, @item["_formatted"]["commit_diff"]))}
        </a>
        <span :for={chunk <- patch.chunks}>
          <div
            :for={line <- chunk.lines}
            class={
              "text-sm break-normal",
              "line-through text-gray-600": MemexWeb.TimelineView.line_type(line) == "remove"
            }
          >
            <span>{raw(MemexWeb.TimelineView.highlight_line_text(line.text, @item["_formatted"]["commit_diff"]))}</span>
          </div>
        </span>
      </div>
      """
    end

    defp parse_patch(patch) do
      {:ok, parsed_diff} = GitDiff.parse_patch(patch)
      parsed_diff |> IO.inspect(label: "92")

      parsed_diff
    end
  end
end
