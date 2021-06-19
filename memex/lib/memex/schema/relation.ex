defmodule Memex.Schema.Relation do
  use Ecto.Schema
  alias Memex.Schema.Document

  @primary_key {:id, :string, autogenerate: false}

  schema "relations" do
    field(:type, :string)
    field(:metadata, :map)
    field(:created_at, :naive_datetime, virtual: true)
    belongs_to(:source, Document)
  end
end
