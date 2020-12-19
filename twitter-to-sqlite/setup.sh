#!/usr/bin/env bash
DIRECTORY=$(cd `dirname $0`/ && pwd)

docker build -t twitter-to-sqlite - < "$DIRECTORY/Dockerfile"
docker run -it --rm --volume "$DIRECTORY":/home twitter-to-sqlite twitter-to-sqlite auth