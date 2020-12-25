defmodule MemexWeb.TimelineView do
  @youtube_url_regex ~r/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i
  @url_regex ~r/https\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/i

  def is_youtube_url(url), do: Regex.match?(@youtube_url_regex, url)

  def parse_youtube_id(url), do: Enum.at(Regex.run(@youtube_url_regex, url), 1)

  def auto_link(text) do
    Regex.replace(@url_regex, text, "<a href=\"\\0\" target=\"_blank\">\\0</a>")
  end

  def days_between(timestamp1, timestamp2) do
    Date.diff(date_from_timestamp(timestamp2), date_from_timestamp(timestamp1))
    |> max(0)
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
end
