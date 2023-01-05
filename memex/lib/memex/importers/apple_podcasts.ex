defmodule Memex.Importers.ApplePodcasts do
  alias Memex.Importer

  use Ecto.Schema
  @primary_key false
  schema "document" do
    field(:provider, :string)
    field(:verb, :string)
    field(:id, :string)
    field(:date_month, :string)
    field(:timestamp_utc, :string)
    field(:timestamp_unix, :integer)
    field(:episode_published_at_utc, :string)
    field(:episode_title, :string)
    field(:episode_description, :string)
    field(:episode_id, :string)
    field(:episode_author, :string)
    field(:episode_webpage_url, :string)
    field(:episode_playback_url, :string)
    field(:podcast_author, :string)
    field(:podcast_title, :string)
    field(:podcast_description_html, :string)
    field(:podcast_id, :string)
    field(:podcast_image_url, :string)
    field(:podcast_category, :string)
    field(:podcast_webpage_url, :string)
  end

  def provider(), do: "Podcasts"

  def default_config() do
    %{
      location:
        "#{System.user_home!()}/Library/Group Containers/243LU875E5.groups.com.apple.podcasts/Documents/MTLibrary.sqlite",
      schedule: :watcher
    }
  end

  def fetch(config) do
    date_correction = "+ 978307200"

    %Importer.Sqlite{
      location: "#{config.location}",
      setup: [],
      query: """
      SELECT
        json_object(
          'provider', 'Podcasts',
          'verb', 'listened',
          'id', 'podcast-' || episode.ZSTORETRACKID,
          'date_month', strftime('%Y-%m', episode.ZLASTDATEPLAYED #{date_correction}, 'unixepoch'),
          'timestamp_utc', datetime(episode.ZLASTDATEPLAYED #{date_correction}, 'unixepoch'),
          'timestamp_unix', CAST(strftime('%s', datetime(episode.ZLASTDATEPLAYED #{date_correction}, 'unixepoch')) as INT),
          'episode_title', episode.ZTITLE,
          'episode_description_html', episode.ZITEMDESCRIPTION,
          'episode_id', CAST(episode.ZSTORETRACKID as text),
          'episode_author', episode.ZAUTHOR,
          'episode_webpage_url', episode.ZWEBPAGEURL,
          'episode_playback_url', episode.ZENCLOSUREURL,
          'episode_published_at_utc', datetime(episode.ZPUBDATE #{date_correction}, 'unixepoch'),
          'podcast_author', pod.ZAUTHOR,
          'podcast_title', pod.ZTITLE,
          'podcast_description', pod.ZITEMDESCRIPTION,
          'podcast_id', CAST(pod.ZSTORECOLLECTIONID as text),
          'podcast_image_url', pod.ZIMAGEURL,
          'podcast_category', pod.ZCATEGORY,
          'podcast_webpage_url', pod.ZWEBPAGEURL
        ) AS json
      FROM ZMTEPISODE AS episode
      JOIN ZMTPODCAST AS pod ON pod.Z_PK = episode.ZPODCAST
      WHERE episode.ZLASTDATEPLAYED IS NOT NULL
      ORDER BY episode.ZLASTDATEPLAYED DESC
      LIMIT 1000
      """
    }
  end

  defmodule TimeLineItem do
    use Surface.Component

    alias MemexWeb.Router.Helpers, as: Routes

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <img
        class="object-cover float-left h-20 w-20 -m-4 rounded-l mr-4"
        width="60"
        height="60"
        src={Routes.photo_path(MemexWeb.Endpoint, :https_proxy, url: @item["podcast_image_url"])}
      />
      <p class="truncate">{raw(@item["_formatted"]["episode_title"])}</p>
      <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
        <a href={@item["episode_webpage_url"]} target="_blank" class="underline">
          {@item["_formatted"]["podcast_title"]} by {@item["_formatted"]["episode_author"]}</a>
      </div>
      """
    end
  end
end
