defmodule Memex.Repo.Migrations.CreateImporterConfig do
  use Ecto.Migration

  def change do
    create table(:importer_config, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:config, :map, null: false)
      timestamps()
    end
  end
end
