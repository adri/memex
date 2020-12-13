#!/usr/bin/env bash
# Formats JSON separated with newlines to an array
# and indexes it in Meilisearch.
#
# Usage: import.sh [importer file]
# Example: import.sh sqlite-to-meilisearch/iMessage.sh

exec $1 \
  | jq -s '.' \
  | curl \
  -X POST "$MEILISEARCH_HOST/indexes/${INDEX_NAME}/documents" \
  --data @-
