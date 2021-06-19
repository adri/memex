defmodule Memex.Repo.Migrations.AddRelations do
  use Ecto.Migration

  def change do
    execute """
    CREATE TABLE "public"."relations" (
      "id" varchar(255) NOT NULL,
      "type" varchar(255) NOT NULL,
      "source_id" varchar(255) NOT NULL,
      "metadata" jsonb NOT NULL DEFAULT '{}',
      "created_at" timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY ("id", "type", "source_id")
    );
    """
  end
end
