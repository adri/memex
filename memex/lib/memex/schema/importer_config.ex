defmodule Memex.Schema.ImporterConfig do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "importer_config" do
    field(:provider, :string)
    field(:display_name, :string)
    field(:encrypted_secrets, Memex.Schema.Encrypted.Map)
    field(:config_overwrite, :map)
    timestamps()
  end
end
