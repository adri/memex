defmodule Memex.Importers.Github do
  @moduledoc """
  [Github Event Documentation](https://docs.github.com/en/developers/webhooks-and-events/events/github-event-types)
  """
  @provider "GitHub"
  @defaults %{"provider" => @provider}
  @ignore_item %{}

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
    field :repo_name, :string
    field :issue_title, :string
    field :issue_body, :string
    field :issue_url, :string
    field :review_body, :string
    field :review_state, :string
    field :review_url, :string
    field :comment_body, :string
    field :comment_url, :string
    field :github_user_name, :string
    field :github_user_avatar, :string
  end

  def provider(), do: @provider

  def default_config() do
    %{
      "user_name" => "",
      "page" => 1,
      "access_token" => "",
      "ignore_repos" => ["adri/notes"]
    }
  end

  def fetch(config) do
    %Importer.JsonEndpoint{
      url: "https://api.github.com/users/#{config["user_name"]}/events?page=#{config["page"]}",
      headers: [
        {"Accept", "application/vnd.github.v3+json"},
        {"User-Agent", "curl/7.64.1"},
        {"Authorization",
         "Basic #{Base.encode64("#{config["user_name"]}:#{config["access_token"]}")}"}
      ]
    }
  end

  def transform(result, config) do
    result
    |> Enum.filter(fn event -> not Enum.member?(config["ignore_repos"], event["repo"]["name"]) end)
    |> Enum.map(&parse_item(&1))
    |> Enum.filter(&match?(%{"verb" => _}, &1))
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
      "id" => "#{@provider}_" <> item["id"],
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

  defmodule TimeLineItem do
    use Surface.Component
    alias MemexWeb.Router.Helpers, as: Routes

    prop item, :map

    def render(assigns) do
      ~F"""
      <p class="text-xs text-gray-400 dark:text-gray-500">
        {raw(@item["_formatted"]["verb"])} in {raw(@item["_formatted"]["repo_name"])}
        <span
          :if={@item["issue_url"] && not Enum.member?(["merged", "requested"], @item["verb"])}
          class="text-xs text-gray-400 dark:text-gray-500"
        >
          <img
            class="rounded-full float-left mr-2"
            src={Routes.photo_path(MemexWeb.Endpoint, :https_proxy, url: @item["github_user_avatar"])}
            width="16"
            height="16"
          />
          <a href={@item["issue_url"]} target="_blank">{raw(@item["_formatted"]["issue_title"])}</a>
        </span>
      </p>
      <p :if={@item["comment_body"]} class="mb-2">
        {raw(@item["_formatted"]["comment_body"])}
      </p>
      <p :if={@item["review_body"]} class="mb-2">
        <span :if={@item["review_state"] === "approved"}>✅</span>

        {raw(@item["_formatted"]["review_body"])}
      </p>
      <p :if={Enum.member?(["merged", "requested"], @item["verb"])} class="mb-2">
        <a href={@item["issue_url"]} target="_blank">{raw(@item["_formatted"]["issue_title"])}</a>
        <div class="text-sm text-gray-400 dark:text-gray-500">{raw(Earmark.as_html!(@item["_formatted"]["issue_body"], compact_output: true))}</div>
      </p>

      <p :if={@item["repo_description"]} class="text-sm text-gray-400 dark:text-gray-400 truncate">
        {raw(@item["_formatted"]["repo_description"])}
      </p>

      <p :if={@item["repo_license"]} class="text-xs text-gray-400 dark:text-gray-500 truncate">
        <span class="capitalize">{@item["repo_license"]}</span>,
        {@item["repo_language"]}, {@item["repo_stars_count"]} stars
      </p>
      """
    end
  end

  defmodule HomepageItem do
    use Surface.Component

    def render(assigns) do
      ~F"""
      test
      """
    end
  end
end
