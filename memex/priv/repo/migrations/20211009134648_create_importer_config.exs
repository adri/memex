defmodule Memex.Repo.Migrations.CreateImporterConfig do
  use Ecto.Migration

  def change do
    create table(:importer_config, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:provider, :string, null: false)
      add(:display_name, :string, null: false)
      add(:encrypted_secrets, :binary, null: false)
      add(:config_overwrite, :map, null: false)
      timestamps()
    end
  end
end
