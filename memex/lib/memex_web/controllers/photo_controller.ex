defmodule MemexWeb.PhotoController do
  use MemexWeb, :controller

  @photos_path "/Users/adrimbp/Pictures/Photos\ Library.photoslibrary/resources/derivatives/masters/"

  def image(conn, %{"path" => path} = params) do
    new_path = @photos_path <> String.replace(params["path"], ".heic", "_4_5005_c.jpeg")

    case File.read(new_path) do
      {:ok, contents} ->
        conn
        |> put_resp_content_type("image/jpeg", "utf-8")
        |> send_resp(200, contents)
      {:error, _} ->
        conn
        |> send_resp(404, "Not found")
    end
  end
end
