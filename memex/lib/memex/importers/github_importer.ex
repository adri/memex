defmodule Memex.Importers.GithubImporter do
  @provider_id "github"
  @defaults %{"provider" => "GitHub"}
  @ignore_item %{}

  alias Memex.Importer

  @doc """
  [Github Event Documentation](https://docs.github.com/en/developers/webhooks-and-events/events/github-event-types)
  """
  def import() do
    # todo: support full and incremental import?
    # todo: return stream for speed and memory use?
    config = config()

    fetch(config)
    |> parse(config)
    |> Importer.bulk_upsert_documents()
  end

  def fetch(config) do
    feed = fetch_feed(config["username"], config["access_token"])

    Jason.decode!(feed.body)
  end

  def parse(items, config) do
    items
    |> Enum.filter(fn event -> not Enum.member?(config["ignore_repos"], event["repo"]["name"]) end)
    |> Enum.map(&parse_item(&1))
    |> Enum.filter(&match?(%{"verb" => _}, &1))
    |> Enum.map(&[body: &1])
  end

  defp config() do
    # todo:
    # - make typed config? So it can generate a UI to edit it?
    # - files to watch or auto-watch files
    Map.merge(
      %{
        "username" => "",
        "access_token" => "",
        "ignore_repos" => ["adri/notes"]
      },
      Importer.config(@provider_id)
    )
  end

  defp fetch_feed(username, access_token, page \\ 1) do
    # Todo: Pagination:
    # Link: <https://api.github.com/resource?page=2>; rel="next",
    #       <https://api.github.com/resource?page=5>; rel="last"

    Tesla.get!(
      "https://api.github.com/users/#{username}/events?page=#{page}",
      headers: [
        {"Accept", "application/vnd.github.v3+json"},
        {"User-Agent", "curl/7.64.1"},
        {"Authorization", "Basic #{Base.encode64("#{username}:#{access_token}")}"}
      ]
    )
  end

  defp parse_item(item) do
    @defaults
    |> Map.merge(parse_common(item))
    |> Map.merge(parse_type(item))
    |> Map.merge(parse_comment(item))
    |> Map.merge(parse_review(item))
    |> Map.merge(parse_issue(item))
    |> Map.merge(parse_user(item))
  end

  defp parse_common(%{} = item) do
    {:ok, date, _} = DateTime.from_iso8601(item["created_at"])

    %{
      "id" => "#{@provider_id}_" <> item["id"],
      "date_month" => Calendar.strftime(date, "%Y-%m"),
      "timestamp_utc" => item["created_at"],
      "timestamp_unix" => DateTime.to_unix(date),
      "repo_name" => item["repo"]["name"]
      # fetch repo for other data?
      # 'repo_description',
      # 'repo_homepage',
      # 'repo_license',
      # 'repo_language',
      # 'repo_stars_count',
    }
  end

  defp parse_type(%{"type" => "WatchEvent"}), do: %{"verb" => "liked"}
  # ignore duplicate events, there is another PullRequestReviewCommentEvent
  defp parse_type(%{"payload" => %{"review" => %{"state" => "commented"}}}), do: @ignore_item
  defp parse_type(%{"type" => "PullRequestReviewEvent"}), do: %{"verb" => "reviewed"}
  defp parse_type(%{"type" => "PullRequestReviewCommentEvent"}), do: %{"verb" => "commented"}
  defp parse_type(%{"type" => "IssueCommentEvent"}), do: %{"verb" => "commented"}

  defp parse_type(%{"type" => "PullRequestEvent"} = item) do
    case item["payload"] do
      %{"action" => "closed", "pull_request" => %{"merged" => true}} -> %{"verb" => "merged"}
      %{"action" => "closed"} -> %{"verb" => "closed"}
      %{"action" => "opened"} -> %{"verb" => "requested"}
      %{"action" => "reopened"} -> %{"verb" => "requested"}
      _ -> @ignore_item
    end
  end

  defp parse_type(_item) do
    @ignore_item
  end

  defp parse_issue(%{"payload" => %{"issue" => issue}}),
    do: %{
      "issue_title" => issue["title"],
      "issue_body" => issue["body"],
      "issue_url" => issue["html_url"]
    }

  defp parse_issue(%{"payload" => %{"pull_request" => issue}}),
    do: %{
      "issue_title" => issue["title"],
      "issue_body" => issue["body"],
      "issue_url" => issue["html_url"]
    }

  defp parse_issue(_item), do: %{}

  defp parse_review(%{"payload" => %{"review" => review}}),
    do: %{
      "review_body" => review["body"],
      "review_state" => review["state"],
      "review_url" => review["html_url"]
    }

  defp parse_review(_item), do: %{}

  defp parse_comment(%{"payload" => %{"comment" => comment}}),
    do: %{
      "comment_body" => comment["body"],
      "comment_url" => comment["html_url"]
    }

  defp parse_comment(_item), do: %{}

  defp parse_user(%{"payload" => %{"issue" => %{"user" => user}}}), do: map_user(user)
  defp parse_user(%{"payload" => %{"pull_request" => %{"user" => user}}}), do: map_user(user)
  defp parse_user(%{"payload" => %{"user" => user}}), do: map_user(user)
  defp parse_user(_item), do: %{}

  defp map_user(user),
    do: %{
      "github_user_name" => user["login"],
      "github_user_avatar" => user["avatar_url"]
    }
end
