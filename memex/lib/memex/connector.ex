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
end
