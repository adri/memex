defmodule Memex.Schema.Encrypted.Map do
  @moduledoc false
  use Cloak.Ecto.Map, vault: Memex.Vault
end
