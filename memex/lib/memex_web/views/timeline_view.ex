defmodule MemexWeb.TimelineView do
  @youtube_url_regex ~r/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i
  @url_regex ~r/https\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/i

  def is_youtube_url(nil), do: false
  def is_youtube_url(url), do: Regex.match?(@youtube_url_regex, url)

  def parse_youtube_id(url), do: Enum.at(Regex.run(@youtube_url_regex, url), 1)

  def auto_link(text) do
    Regex.replace(@url_regex, text, "<a href=\"\\0\" target=\"_blank\">\\0</a>")
  end

  def days_between(timestamp1, timestamp2) do
    Date.diff(date_from_timestamp(timestamp2), date_from_timestamp(timestamp1))
    |> max(0)
  end

  def time_between(timestamp1, timestamp2) do
    DateTime.diff(date_from_timestamp(timestamp2), date_from_timestamp(timestamp1))
  end

  def timestamp_start_between(results, time_range) do
    results
    |> Enum.filter(fn hit ->
      hit["timestamp_start_unix"] && Enum.member?(time_range, hit["timestamp_start_unix"])
    end)
  end

  def count_results_between(results, timestamp) do
    results
    |> Enum.filter(fn hit ->
      hit["timestamp_start_unix"] &&
        Enum.member?(hit["timestamp_start_unix"]..hit["timestamp_unix"], timestamp)
    end)
    |> Enum.count()
  end

  def timeline_classes(results, hit, index) do
    previous_hit = Enum.at(results, index - 1)["timestamp_unix"]
    previous_results_between = MemexWeb.TimelineView.count_results_between(results, previous_hit)
    results_between = MemexWeb.TimelineView.count_results_between(results, hit["timestamp_unix"])

    timeline_classes =
      if results_between > previous_results_between do
        " rounded-t"
      else
        ""
      end

    previous_timeline_classes =
      case previous_results_between do
        0 -> "bg-gray-400 dark:bg-gray-700 " <> timeline_classes
        1 -> "bg-gray-500 dark:bg-gray-500 " <> timeline_classes
        2 -> "bg-gray-600 dark:bg-gray-300 " <> timeline_classes
        _ -> "bg-gray-700 dark:bg-gray-100 " <> timeline_classes
      end

    timeline_classes =
      case results_between do
        0 -> "bg-gray-400 dark:bg-gray-700 " <> timeline_classes
        1 -> "bg-gray-500 dark:bg-gray-500 " <> timeline_classes
        2 -> "bg-gray-600 dark:bg-gray-300 " <> timeline_classes
        _ -> "bg-gray-700 dark:bg-gray-100 " <> timeline_classes
      end

    {previous_timeline_classes, timeline_classes}
  end

  def human_time_between(timestamp1, timestamp2) do
    diff = abs(time_between(timestamp1, timestamp2))

    cond do
      diff < 60 ->
        "less than a minute"

      diff > 60 && diff < 120 ->
        "1 minute"

      diff >= 120 && diff < 3600 ->
        "#{div(diff, 60)} minutes"

      diff >= 3600 && diff < 7200 ->
        min = rem(diff, 3600) |> div(60)
        "a 1 hour and #{min} minutes"

      diff >= 7200 ->
        min = rem(diff, 3600) |> div(60)
        "#{div(diff, 3600)} hours and #{min} minutes"
    end
  end

  def icon_by_provider(provider) do
    case provider do
      "Safari" ->
        "/images/safari-small.png"

      "MoneyMoney" ->
        "/images/MoneyMoney-small.png"

      "iMessage" ->
        "/images/iMessage-small.png"

      "GitHub" ->
        "/images/GitHub-small.png"

      "Photos" ->
        "/images/Photos-small.png"

      "terminal" ->
        "/images/terminal-small.png"

      "Twitter" ->
        "/images/Twitter-small.png"

      "git-notes" ->
        "/images/GitHub-small.png"

      "Arc" ->
        "/images/Arc-small.png"

      _ ->
        nil
    end
  end

  def date_from_timestamp(timestamp) do
    cond do
      is_integer(timestamp) ->
        timestamp

      is_float(timestamp) ->
        round(timestamp)

      true ->
        String.to_integer(timestamp)
    end
    |> DateTime.from_unix!()
  end

  def file_header(patch, status) do
    from = patch.from
    to = patch.to

    case status do
      "changed" -> from
      "renamed" -> "#{from} -> #{to}"
      "removed" -> from
      "added" -> to
    end
  end

  def patch_status(patch) do
    from = patch.from
    to = patch.to

    cond do
      !from -> "added"
      !to -> "removed"
      from == to -> "changed"
      true -> "renamed"
    end
  end

  def nl2br(nil), do: ""

  def nl2br(text) do
    text
    |> String.trim()
    |> String.replace("\n", "<br />")
  end

  def line_type(line), do: to_string(line.type)

  def line_text("+" <> text), do: "" <> nl2br(text)
  def line_text("-" <> text), do: "" <> nl2br(text)
  def line_text(text), do: " " <> nl2br(text)

  @highlight_regex ~r/<em>(.*)<\/em>/u
  def highlight_line_text(text, _highlight_text) when is_nil(text), do: line_text(text)

  def highlight_line_text(text, highlight_text) do
    with [_, highlights] <- Regex.run(@highlight_regex, highlight_text) do
      text
      |> String.replace(highlights, "<em>#{highlights}</em>")
      |> line_text()
    else
      _e -> line_text(text)
    end
  end

  def number_short(number) do
    cond do
      number < 1000 ->
        number

      number < 1_000_000 ->
        "#{Float.round(number / 1000, 1)}K"

      number < 1_000_000_000 ->
        "#{Float.round(number / 1_000_000, 1)}M"

      true ->
        number
    end
  end

  def number_to_currency(_number, nil), do: nil
  def number_to_currency(nil, _options), do: nil

  def number_to_currency(number, currency) do
    {:ok, money} = Money.parse(number, currency)

    money
    |> Money.to_string(symbol: true)
  end
end
