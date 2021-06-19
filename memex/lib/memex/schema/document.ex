defmodule Memex.Schema.Document do
  use Ecto.Schema
  alias Memex.Schema.Relation

  @primary_key {:id, :string, autogenerate: false}

  schema "documents" do
    field(:body, :map)
    field(:created_at, :naive_datetime)
    field(:update_at, :naive_datetime, virtual: true)
    has_many(:relations, Relation, foreign_key: :id)
  end
end
