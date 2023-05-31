defmodule Memex.Schema.ImporterConfig do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "importer_config" do
    field(:provider, :string, null: false)
    field(:display_name, :string, null: false)
    field(:encrypted_secrets, Memex.Schema.Encrypted.Map, null: false)
    field(:config_overwrite, :map, null: false)
    timestamps()
  end
end
