#!/usr/bin/env bash

INDEX_URL=${INDEX_URL:="${MEILISEARCH_HOST}/indexes/${INDEX_NAME}"}

# Create index
curl -X POST "${MEILISEARCH_HOST}/indexes" \
  --data '{
    "uid": "'"${INDEX_NAME}"'",
    "primaryKey": "id"
  }'

# Always sort by time to create a timeline
curl -X POST "${INDEX_URL}/settings/ranking-rules" \
  --data '[ "desc(timestamp_unix)" ]'

# Configure distinct attributes
curl -X POST "${INDEX_URL}/settings/distinct-attribute" \
  --data '"id"'

# Configure facets
curl -X POST "${INDEX_URL}/settings/attributes-for-faceting" \
  --data '[ "person_name", "date_month", "provider", "verb" ]'

