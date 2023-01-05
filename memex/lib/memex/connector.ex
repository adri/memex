defmodule Memex.Connector do
  alias Exqlite.Basic, as: Sqlite3
  alias Exqlite.Connection

  def sqlite_json(path, query, args \\ [], setup \\ [], key \\ nil) do
    options =
      [database: path, key: key, mode: :readonly, cipher_compatibility: 3]
      |> Keyword.filter(fn {_k, v} -> not is_nil(v) end)

    with {:ok, conn} <- Connection.connect(options),
         {:ok, _} <- sqlite_queries(conn, setup),
         {:ok, rows} <- sqlite_query(conn, query, args) do
      {:ok, Enum.map(rows, &Jason.decode!(&1))}
    end
  end

  defp sqlite_queries(conn, queries) do
    Enum.reduce_while(queries, {:ok, []}, fn query, {:ok, acc} ->
      case sqlite_query(conn, query) do
        {:ok, rows} -> {:cont, {:ok, [rows | acc]}}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  defp sqlite_query(conn, query, args \\ []) do
    with {:ok, rows, _columns} <- Sqlite3.rows(Sqlite3.exec(conn, query, args)) do
      {:ok, rows}
    end
  end

  def cmd(command, args \\ []) do
    case System.cmd(command, args) do
      {result, 0} -> {:ok, result}
      {result, exit_status} -> {:error, result, exit_status}
    end
  end

  def shell(command) do
    case System.shell(command) do
      {result, 0} -> {:ok, result}
      {result, exit_status} -> {:error, result, exit_status}
    end
  end

  def json_file(path, compresed) do
    path
    |> File.stream!(
      if compresed do
        [:compressed]
      else
        []
      end
    )
    |> Enum.into("")
    |> Jason.decode()
  end
end
