defmodule Memex.Schema.Document do
  use Ecto.Schema
  alias Memex.Schema.Relation
  alias Memex.Schema.ImporterLog

  @primary_key {:id, :string, autogenerate: false}

  schema "documents" do
    field(:body, :map)
    field(:created_at, :utc_datetime)
    field(:update_at, :utc_datetime, virtual: true)
    has_many(:relations, Relation, foreign_key: :id)
    belongs_to(:importer_log, ImporterLog, type: :binary_id)
  end
end
