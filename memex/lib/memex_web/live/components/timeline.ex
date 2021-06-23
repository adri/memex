defmodule MemexWeb.Timeline do
  use Surface.Component

  alias MemexWeb.Timeline.Card
  alias MemexWeb.Timeline.ProviderIcon
  alias MemexWeb.Timeline.Time
  alias MemexWeb.Timeline.VerticalLine
  alias MemexWeb.Timeline.DateBorder
  alias MemexWeb.Router.Helpers, as: Routes

  prop(query, :string, required: true)
  prop(page, :number, required: true)
  prop(results, :list, required: true)

  def render(assigns) do
    ~F"""
    <div id={"hits-#{unique_query_id(@query)}"} phx-update="replace">
      <div :for.with_index={{hit, index} <- @results}>
        <div
          :if={index !== 0}
          :for={hit <- MemexWeb.TimelineView.timestamp_start_between(@results, hit["timestamp_unix"]..previous_timestamp(@results, index))}
          class="flex w-auto items-start group ml-12 md:ml-20">
            <VerticalLine class={"#{previous_timeline_classes(@results, hit, index)}"} />
            <Time date={date(hit["timestamp_start_unix"])} />
            <ProviderIcon provider={hit["provider"]} />
            <div class="text-xs text-gray-500 p-3 dark:text-gray-500">
              <span :if={hit["verb"] === "visited"}>Arrived at {hit["place_name"] || hit["place_address"]}</span>
              <span :if={hit["verb"] === "moved"}>Started {hit["activity_type"]}</span>
              <span  class="hidden md:inline-block text-xs transition-opacity opacity-0 group-hover:opacity-100">
                <span :if={hit["verb"] === "visited"}>and stayed</span>
                for {MemexWeb.TimelineView.human_time_between(hit["timestamp_unix"], hit["timestamp_start_unix"])}.
              </span>
            </div>
        </div>
        <div :if={index === 0 || days_between(hit["timestamp_unix"], @results, index) > 0} class="flex w-auto items-start group ml-12 md:ml-20">
          <VerticalLine class={"#{timeline_classes(@results, hit, index)}"} />
          <ProviderIcon />
          <DateBorder date={date(hit["timestamp_unix"])} days_between={days_between(hit["timestamp_unix"], @results, index)}/>
        </div>
        <div id={"hit-#{hit["id"]}"} class="ml-12 md:ml-20">
          <div class="flex w-auto items-start">
            <VerticalLine class={"#{timeline_classes(@results, hit, index)}"} />
            <Time date={date(hit["timestamp_unix"])} />
            <ProviderIcon provider={hit["provider"]} />
            <Card>
              <#template slot="content">
                <a :if={hit["provider"] === "Safari"} href={hit["website_url"]} target="_blank">
                  <p class="truncate">{raw hit["_formatted"]["website_title"]}</p>
                  <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
                      {hit["device_name"]}: {raw hit["_formatted"]["website_url"]}
                  </div>
                </a>
                <a :if={hit["provider"] === "GitHub"} href={"#{hit["repo_homepage"]}"} target="_blank">
                    {raw hit["_formatted"]["repo_name"]}
                    <p class="text-sm text-gray-400 dark:text-gray-400 truncate">
                        {raw hit["_formatted"]["repo_description"]}
                    </p>
                    <p class="text-xs text-gray-400 dark:text-gray-500 truncate">
                        <span class="capitalize">{hit["repo_license"]}</span>,
                        {hit["repo_language"]}, {hit["repo_stars_count"]} stars
                    </p>
                </a>
                <div :if={hit["provider"] === "iMessage"} >
                  <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
                      {case hit["message_direction"] do
                          "sent" -> "Sent to "
                          "received" -> "Received from "
                      end}
                      {raw hit["_formatted"]["person_name"]}
                  </div>
                    {raw hit["_formatted"]["message_text"]}
                </div>
                <div :if={hit["provider"] === "MoneyMoney"}>
                  <span class="font-mono">{MemexWeb.TimelineView.number_to_currency(abs(hit["transaction_amount"]), hit["transaction_currency"])}</span>
                  {if hit["transaction_amount"] < 0 do "to " else "from " end}
                  <span>{raw hit["_formatted"]["transaction_recipient"]}</span>
                  <span :if={hit["_formatted"]["transaction_category"] != ""} class="float-right rounded-full dark:bg-gray-700 p-2 text-xs">{raw hit["_formatted"]["transaction_category"]}</span>
                  <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
                      {raw hit["_formatted"]["transaction_account_name"]} - {raw hit["_formatted"]["transaction_purpose"]}
                  </div>
                </div>
                <pre :if={hit["provider"] === "terminal"} class="text-sm overflow-scroll"><code>{raw String.replace(String.trim(hit["_formatted"]["command"]), "\n", "<br />")}</code></pre>
                <div :if={hit["provider"] === "Photos"}>
                  <img class="object-cover float-left h-20 w-20 -m-4 rounded-l mr-4" width="60" height="60" src={"#{Routes.photo_path(@socket, :image, hit["photo_file_path"])}"} />
                  <p class="text-xs truncate">{raw Enum.join(hit["_formatted"]["photo_labels"], ", ")}</p>
                  <p class="text-xs text-gray-400 dark:text-gray-500">
                      {raw hit["_formatted"]["device_name"]}
                  </p>
                </div>
                <div :if={hit["provider"] === "Twitter"}>
                  <span :if={hit["tweet_liked"] != 0} class="float-right rounded-full dark:bg-gray-700 ml-2 p-2 text-xs">Liked</span>
                  <span :if={hit["tweet_retweeted"] != 0} class="float-right rounded-full dark:bg-gray-700 p-2 text-xs">Retweeted</span>
                  <a href={"https://twitter.com/#{hit["tweet_user_screen_name"]}"} class="block text-xs text-gray-300 dark:text-gray-500 truncate" target="_blank">
                    <img class="rounded-full float-left mr-2 mb-1" src={"#{hit["tweet_user_avatar_url"]}"} width="20" height="20" />
                    {raw hit["_formatted"]["tweet_user_screen_name"]}<span :if={hit["_formatted"]["tweet_user_location"] != ""}>, {raw hit["_formatted"]["tweet_user_location"]}</span>
                  </a>
                  <a href={"#{hit["tweet_url"]}"} target="_blank">
                    {raw MemexWeb.TimelineView.auto_link(hit["_formatted"]["tweet_full_text"])}
                  </a>
                  <a :for={media <- hit["tweet_media"]} href={media["url"]} target="_blank">
                    <img class="object-cover h-20 w-20 rounded-md mr-4 mt-4" width="60" height="60" src={media["url"]} />
                  </a>
                </div>
                <div :if={hit["provider"] === "git-notes"}>
                  <div :for={patch <- parse_patch(hit["commit_diff"])}>
                    <a href={"obsidian://open?#{URI.encode_query(%{"vault" => "Wiki_Synced", "file" => MemexWeb.TimelineView.nl2br(patch.from)})}"} target="_blank">
                        {MemexWeb.TimelineView.nl2br(patch.from)}
                    </a>
                    <span :for={chunk <- patch.chunks}>
                      <pre :for={line <- chunk.lines} class={"text-sm overflow-scroll #{case MemexWeb.TimelineView.line_type(line) do
                        "remove" -> "line-through text-gray-600"
                        _ -> "" end}"}><code>{raw MemexWeb.TimelineView.highlight_line_text(line.text, hit["_formatted"]["commit_diff"])}</code></pre>
                    </span>
                  </div>
                </div>
                <div :if={hit["provider"] === "Arc"} class="flex cursor-pointer" phx-click="open-sidebar" phx-value-id={"#{hit["id"]}"}>
                  <div :if={hit["verb"] === "visited"} class="flex-grow truncate">
                    {raw hit["_formatted"]["place_name"] || hit["_formatted"]["place_address"]}
                    <p class="text-xs text-gray-400 dark:text-gray-500">
                      Spent {MemexWeb.TimelineView.human_time_between(hit["timestamp_unix"], hit["timestamp_start_unix"])}.
                      <span :if={hit["place_address"]}>{raw hit["_formatted"]["place_address"]}</span>
                    </p>
                  </div>
                  <div :if={hit["verb"] === "moved"} class="flex-grow truncate">
                    Finished {raw hit["_formatted"]["activity_type"]}
                    <p class="text-xs text-gray-400 dark:text-gray-500">
                      {MemexWeb.TimelineView.human_time_between(hit["timestamp_unix"], hit["timestamp_start_unix"])}.
                    </p>
                  </div>
                </div>
              </#template>
              <#template slot="media">
                <img :if={MemexWeb.TimelineView.is_youtube_url(hit["website_url"])} class="object-cover float-left h-20 w-20 -m-4 rounded-l mr-4" width="60" height="60" src={"http://i3.ytimg.com/vi/#{MemexWeb.TimelineView.parse_youtube_id(hit["website_url"])}/mqdefault.jpg"} />
                <img :if={hit["verb"] === "visited"} class="object-cover h-24 w-24 -m-4 rounded-l mr-4" width="82" height="82" src={"https://api.mapbox.com/styles/v1/mapbox/dark-v10/static/pin-l-embassy+f74e4e(#{hit["place_longitude"]},#{hit["place_latitude"]})/#{hit["place_longitude"]},#{hit["place_latitude"]},15/100x100@2x?access_token=#{System.get_env("MAPBOX_API_KEY")}"} />
              </#template>
              <#template slot="right">
                  <button
                    :for={related <- hit["_relations"] || []}
                    phx-click="open-sidebar"
                    phx-value-type="person"
                    phx-value-name={"#{related["related"]["person_name"]}"}
                    class="inline-flex items-center justify-center text-xs px-3 pr-1 py-1 dark:bg-gray-800 rounded-full">
                    {shared(related["type"])}
                    <b class="ml-1">{first_name(related["related"]["person_name"])}</b>
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" class="ml-1 text-gray-400 dark:text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
                  </button>
                  <button :for={person_name <- to_list(hit["person_name"])}
                    phx-click="open-sidebar"
                    phx-value-type="person"
                    phx-value-name={person_name}
                    class="inline-flex items-center justify-center text-xs px-3 pr-1 py-1 dark:bg-gray-800 rounded-full"
                    >{first_name(person_name)} <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" class="ml-1 text-gray-400 dark:text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg></button>
                  <div :if={hit["activity_heart_rate_average"]} class="flex items-center ml-2 text-xs space-x-2">
                    <span :if={hit["activity_heart_rate_average"]} class="flex p-2 space-x-1 items-center rounded-md border text-gray-500 border-gray-300 dark:border-gray-700 ">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                      </svg>
                      {round(hit["activity_heart_rate_average"])}
                    </span>
                    <span :if={hit["activity_floors_ascended"] && hit["activity_floors_ascended"] + hit["activity_floors_descended"] != 0} class="flex ml-2 p-2 space-x-1 items-center rounded-md text-gray-500 border dark:border-gray-700 border-gray-300">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                          <path d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z" />
                      </svg>
                      {round(hit["activity_floors_ascended"] + hit["activity_floors_descended"])}
                    </span>
                </div>
              </#template>
            </Card>
          </div>
        </div>
      </div>
      <div id="loader" phx-hook="InfiniteScroll" data-page={"#{@page}"}></div>
    </div>
    """
  end

  defp parse_patch(patch) do
    {:ok, parsed_diff} = GitDiff.parse_patch(patch)

    parsed_diff
  end

  defp shared(type) do
    case type do
      "shared_by" -> "From "
      "shared_to" -> "To "
    end
  end

  defp first_name(name) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

  defp to_list(nil), do: []
  defp to_list(list) when is_list(list), do: list
  defp to_list(item), do: [item]

  defp date(timestamp) do
    timestamp
    |> MemexWeb.TimelineView.date_from_timestamp()
    |> DateTime.shift_zone!("Europe/Amsterdam")
  end

  defp days_between(timestamp, results, index) do
    MemexWeb.TimelineView.days_between(timestamp, previous_timestamp(results, index))
  end

  defp previous_timestamp(results, index), do: Enum.at(results, index - 1)["timestamp_unix"]
  defp unique_query_id(query), do: Base.encode16(query)

  defp timeline_classes(results, hit, index) do
    previous_results_between =
      MemexWeb.TimelineView.count_results_between(results, previous_timestamp(results, index))

    results_between = MemexWeb.TimelineView.count_results_between(results, hit["timestamp_unix"])

    timeline_classes =
      if results_between > previous_results_between do
        " rounded-t"
      else
        ""
      end

    case results_between do
      0 -> "bg-gray-400 dark:bg-gray-700 " <> timeline_classes
      1 -> "bg-gray-500 dark:bg-gray-500 " <> timeline_classes
      2 -> "bg-gray-600 dark:bg-gray-300 " <> timeline_classes
      _ -> "bg-gray-700 dark:bg-gray-100 " <> timeline_classes
    end
  end

  defp previous_timeline_classes(results, hit, index) do
    previous_results_between =
      MemexWeb.TimelineView.count_results_between(results, previous_timestamp(results, index))

    results_between = MemexWeb.TimelineView.count_results_between(results, hit["timestamp_unix"])

    timeline_classes =
      if results_between > previous_results_between do
        " rounded-t"
      else
        ""
      end

    case previous_results_between do
      0 -> "bg-gray-400 dark:bg-gray-700 " <> timeline_classes
      1 -> "bg-gray-500 dark:bg-gray-500 " <> timeline_classes
      2 -> "bg-gray-600 dark:bg-gray-300 " <> timeline_classes
      _ -> "bg-gray-700 dark:bg-gray-100 " <> timeline_classes
    end
  end
end
