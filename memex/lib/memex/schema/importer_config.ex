defmodule Memex.Schema.ImporterConfig do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "importer_config" do
    field(:provider, :string, null: false)
    field(:display_name, :string, null: false)
    field(:encrypted_secrets, Memex.Schema.Encrypted.Map, null: false)
    field(:config_overwrite, :map, null: false)
    timestamps()
  end
end
