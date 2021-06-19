#!/usr/bin/env bash

# Start Postgres
docker compose up -d
dockerize -wait-retry-interval 5s -wait tcp://127.0.0.1:65432 -timeout 5m &> /dev/null

# Start Elixir frontend
cd memex
mix deps.get
mix ecto.migrate
cd assets && yarn && cd ..
iex -S mix phx.server
