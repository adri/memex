defmodule Memex.Repo.Migrations.CreateImporterConfig do
  use Ecto.Migration

  def change do
    create table(:importer_config, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:provider, :string)
      add(:display_name, :string)
      add(:encrypted_secrets, :binary)
      add(:config_overwrite, :map)
      timestamps()
    end
  end
end
