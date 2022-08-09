defmodule Memex.Connector do
  alias Exqlite.Basic, as: Sqlite3
  alias Exqlite.Connection

  def sqlite(path, query, args \\ []) do
    with {:ok, conn} <- Connection.connect(database: path, journal_mode: :wal),
         {:ok, rows, _columns} <- Sqlite3.exec(conn, query, args) |> Sqlite3.rows() do
      {:ok, rows}
    end
  end

  def sqlite_json(path, query, args \\ []) do
    with {:ok, rows} <- sqlite(path, query, args) do
      {:ok, Enum.map(rows, &Jason.decode!(&1))}
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
