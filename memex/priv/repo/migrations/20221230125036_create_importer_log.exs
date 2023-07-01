defmodule Memex.Repo.Migrations.CreateImporterLog do
  use Ecto.Migration

  def change do
    create table(:importer_log, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:state, :string)
      add(:log, :text)
      add(:config_id, references(:importer_config, type: :string))
      timestamps()
    end

    alter table(:documents) do
      add(:importer_log_id, references(:importer_log, type: :uuid))
    end
  end
end
