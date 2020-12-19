defmodule MemexWeb.TimelineView do
  @youtube_url_regex ~r/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i
  @url_regex ~r/https\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/i

  def is_youtube_url(url), do: Regex.match?(@youtube_url_regex, url)

  def parse_youtube_id(url), do: Enum.at(Regex.run(@youtube_url_regex, url), 1)

  def auto_link(text) do
    Regex.replace(@url_regex, text, "<a href=\"\\0\" target=\"_blank\">\\0</a>")
  end
end
