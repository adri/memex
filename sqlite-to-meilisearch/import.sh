INDEX=memex
MEILISEARCH_HOST=http://127.0.0.1:7700

# Formats JSON newlines to an array and indexes it in Meilisearch
exec $1 \
  | jq -s '.' \
  | curl \
  -X POST "$MEILISEARCH_HOST/indexes/${INDEX}/documents" \
  --data @-
