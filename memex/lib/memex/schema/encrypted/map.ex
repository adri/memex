defmodule Memex.Schema.Encrypted.Map do
  use Cloak.Ecto.Map, vault: Memex.Vault
end
