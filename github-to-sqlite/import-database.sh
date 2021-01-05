#!/usr/bin/env bash
DIRECTORY=$(cd `dirname $0`/ && pwd)

docker build -t github-to-sqlite - < "$DIRECTORY/Dockerfile"
docker run -it --rm --volume "$DIRECTORY":/home github-to-sqlite sh -c "
  github-to-sqlite repos github.db $GITHUB_USER_NAME \
  && github-to-sqlite starred github.db
"

