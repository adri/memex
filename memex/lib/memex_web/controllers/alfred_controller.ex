defmodule MemexWeb.AlfredController do
  use MemexWeb, :controller

  alias Memex.Search.Query
  alias Memex.Search.Postgres, as: Search

  def search(conn, params) do
    query = %{Query.from_string(params["q"] || "") | limit: 20}

    with {:ok, results} <- Search.query(query) do
      conn
      |> put_resp_content_type("application/json", "utf-8")
      |> send_resp(200, Jason.encode!(alfred_format_hits(results)))
    else
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json", "utf-8")
        |> send_resp(400, Jason.encode!(%{"error" => error}))
    end
  end

  defp alfred_format_hits(hits) do
    %{
      items: hits |> Enum.map(&alfred_format_hit(&1))
    }
  end

  defp alfred_format_hit(hit) do
    %{
      # uid: hit["id"], # Exclude ID to enforce the item order
      type: "default",
      title: alfred_format_title(hit),
      subtitle: alfred_format_subtitle(hit),
      arg: alfred_format_arg(hit),
      # autocomplete: "Desktop",
      valid: alfred_format_valid(hit),
      icon: %{
        path: alfred_format_icon_path(hit)
      },
      text: %{
        copy: alfred_format_title(hit),
        largetype: alfred_format_title(hit)
      }
    }
  end

  defp alfred_format_arg(%{"provider" => "Safari"} = hit), do: hit["website_url"]
  defp alfred_format_arg(%{"provider" => "Github"} = hit), do: hit["repo_homepage"]
  defp alfred_format_arg(%{"provider" => "Twitter"} = hit), do: hit["tweet_url"]
  defp alfred_format_arg(_hit), do: nil

  defp alfred_format_title(%{"provider" => "Safari"} = hit), do: hit["website_title"]
  defp alfred_format_title(%{"provider" => "iMessage"} = hit), do: hit["message_text"]
  defp alfred_format_title(%{"provider" => "GitHub"} = hit), do: hit["repo_name"]
  defp alfred_format_title(%{"provider" => "Twitter"} = hit), do: hit["tweet_full_text"]
  defp alfred_format_title(%{"provider" => "terminal"} = hit), do: hit["command"]

  defp alfred_format_title(%{"provider" => "MoneyMoney"} = hit),
    do:
      MemexWeb.TimelineView.number_to_currency(
        abs(hit["transaction_amount"]),
        hit["transaction_currency"]
      ) <> ": #{hit["transaction_recipient"]} #{hit["transaction_category"]}"

  defp alfred_format_title(_hit), do: "unknown"

  defp alfred_format_subtitle(%{"provider" => "Safari"} = hit), do: hit["website_url"]
  defp alfred_format_subtitle(%{"provider" => "Twitter"} = hit), do: hit["tweet_user_screen_name"]

  defp alfred_format_subtitle(%{"provider" => "MoneyMoney"} = hit),
    do: "#{hit["transaction_account_name"]} #{hit["transaction_purpose"]}"

  defp alfred_format_subtitle(%{"provider" => "GitHub"} = hit),
    do:
      "#{hit["repo_description"]} #{hit["repo_license"]} #{hit["repo_language"]} #{hit["repo_stars_count"]} stars"

  defp alfred_format_subtitle(%{"provider" => "iMessage"} = hit) do
    case hit["message_direction"] do
      "sent" -> "Sent to "
      "received" -> "Received from "
    end <>
      hit["person_name"]
  end

  defp alfred_format_subtitle(_hit), do: ""

  defp alfred_format_icon_path(hit),
    do: Path.absname("assets/static/" <> MemexWeb.TimelineView.icon_by_provider(hit["provider"]))

  defp alfred_format_valid(hit) do
    case alfred_format_arg(hit) do
      nil -> false
      _ -> true
    end
  end
end
