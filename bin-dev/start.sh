#!/usr/bin/env bash

# Start Meilisearch
./meilisearch --no-analytics=no --no-sentry=no --http-payload-size-limit=104857600 &

# Start Elixir frontend
cd memex
mix deps.get
MEILISEARCH_HOST=$MEILISEARCH_HOST iex -S mix phx.server
