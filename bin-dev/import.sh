#!/usr/bin/env bash
# Formats JSON separated with newlines to an array
# and indexes it in Meilisearch.
#
# Usage: import.sh [importer file]
# Example: import.sh sqlite-to-json/iMessage.sh

exec $1 \
  | jq -s '.' \
  | curl \
  -H 'Content-Type: application/json' \
  -X POST "$MEILISEARCH_HOST/indexes/${INDEX_NAME}/documents" \
  --data @-
