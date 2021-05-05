defmodule Memex.Search.Sidebars do
  @moduledoc """
  Manages opening and closing of sidebars. There should always be a closed
  sidebar at the end so that a new one can animate in.
  """
  @closed %{"closed" => true}

  def init(), do: append_closed([])

  def opened(data), do: Map.merge(data, %{"closed" => false})

  def open(sidebars, data),
    do: append_closed(Enum.drop(sidebars, -1) ++ [opened(data)])

  def close_last([%{"closed" => false} = _data]), do: append_closed([])
  def close_last(sidebars), do: append_closed(Enum.drop(sidebars, -2))

  defp append_closed(sidebars), do: sidebars ++ [@closed]
end
