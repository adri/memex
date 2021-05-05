defmodule MemexWeb.TimelineView do
  @youtube_url_regex ~r/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i
  @url_regex ~r/https\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/i
  alias MemexWeb.Router.Helpers, as: Routes

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
  def highlight_line_text(text, highlight_text) do
    with [_, highlights] <- Regex.run(@highlight_regex, highlight_text) do
      text
      |> String.replace(highlights, "<em>#{highlights}</em>")
      |> line_text()
    else
      _e -> line_text(text)
    end
  end
end
