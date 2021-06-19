defmodule Memex.Repo.Migrations.AddDocuments do
  use Ecto.Migration

  def change do
    execute """
    CREATE TABLE "public"."documents" (
      "id" varchar(255) GENERATED ALWAYS AS (body ->> 'id') stored,
      "body" jsonb NOT NULL,
      "created_at" timestamptz GENERATED ALWAYS AS (to_timestamp((body ->> 'timestamp_unix')::int)) stored,
      "updated_at" timestamptz NOT NULL DEFAULT now(),
      "search" tsvector GENERATED ALWAYS AS (
        to_tsvector('simple',
                    COALESCE(body ->> 'place_name', '')
          || ' ' || COALESCE(body ->> 'verb', '')
          || ' ' || COALESCE(body ->> 'provider', '')
          || ' ' || COALESCE(body ->> 'place_name', '')
          || ' ' || COALESCE(body ->> 'place_address', '')
          || ' ' || COALESCE(translate(body ->> 'website_url', '@./', '  '), '')
          || ' ' || COALESCE(body ->> 'website_title', '')
          || ' ' || COALESCE(body ->> 'device_name', '')
          || ' ' || COALESCE(body ->> 'command', '')
          || ' ' || COALESCE(translate(body ->> 'message_text', '@./', '  '), '')
          || ' ' || COALESCE(body ->> 'message_service', '')
          || ' ' || COALESCE(body ->> 'message_direction', '')
          || ' ' || COALESCE(body ->> 'person_name', '')
          || ' ' || COALESCE(body ->> 'repo_name', '')
          || ' ' || COALESCE(body ->> 'repo_homepage', '')
          || ' ' || COALESCE(body ->> 'repo_description', '')
          || ' ' || COALESCE(body ->> 'repo_language', '')
          || ' ' || COALESCE(body ->> 'transaction_amount', '')
          || ' ' || COALESCE(body ->> 'transaction_purpose', '')
          || ' ' || COALESCE(body ->> 'transaction_category', '')
          || ' ' || COALESCE(body ->> 'transaction_recipient', '')
          || ' ' || COALESCE(body ->> 'tweet_user_screen_name', '')
          || ' ' || COALESCE(body ->> 'tweet_user_name', '')
          || ' ' || COALESCE(translate(body ->> 'tweet_full_text', '@./', '  '), '')
          || ' ' || COALESCE(translate(body ->> 'commit_diff', '@./', '  '), '')
          || ' ' || COALESCE(body ->> 'photo_kind', '')
          || ' ' || COALESCE(body ->> 'photo_labels', '')
          || ' ' || COALESCE(body ->> 'photo_file_name', '')
        )
      ) STORED,
      PRIMARY KEY ("id")
    );
    """
    execute "CREATE INDEX idx_documents_created_at ON documents (created_at DESC)"
    execute "CREATE INDEX idx_documents_search ON documents USING GIN(search)"
    execute "CREATE INDEX idx_documents_body ON documents USING GIN(body jsonb_path_ops)"
  end
end
