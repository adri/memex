#!/usr/bin/env bash
DIRECTORY=$(cd `dirname $0`/ && pwd)

docker build -t github-to-sqlite - < "$DIRECTORY/Dockerfile"
docker run -it --rm --volume "$DIRECTORY":/home github-to-sqlite github-to-sqlite auth