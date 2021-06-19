#!/usr/bin/env bash

fswatch -0 -or ~/Library/Safari/ | xargs -0 -I {} env LIMIT=10 import.sh ./sqlite-to-json/Safari.sh
