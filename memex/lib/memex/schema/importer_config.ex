defmodule Memex.Schema.ImporterConfig do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "importer_config" do
    field(:config, :map, null: false)
    timestamps()
  end
end
