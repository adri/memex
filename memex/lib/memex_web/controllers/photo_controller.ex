defmodule MemexWeb.PhotoController do
  use MemexWeb, :controller

  @photos_path "/Users/adrimbp/Pictures/Photos\ Library.photoslibrary/resources/derivatives/masters/"

  def image(conn, %{"path" => path} = _params) do
    new_path =
      @photos_path <>
        String.replace(path, [".jpeg", ".heic", ".mov", ".png"], "_4_5005_c.jpeg")

    case File.read(new_path) do
      {:ok, contents} ->
        conn
        |> put_resp_content_type("image/jpeg", "utf-8")
        |> send_resp(200, contents)

      {:error, _} ->
        send_resp(conn, 404, "Not found")
    end
  end

  # Insecure but needed to avoid HTTPS on localhost
  def https_proxy(conn, %{"url" => url} = _params) do
    url
    |> Tesla.get()
    |> case do
      {:ok, %{status: 200} = response} ->
        conn
        |> merge_resp_headers(
          Enum.filter(response.headers, fn {key, _} ->
            Enum.member?(["content-type", "content-length", "content-disposition", "ETag"], key)
          end)
        )
        |> send_resp(200, response.body)

      _ ->
        send_resp(conn, 404, "Not found")
    end
  end
end
