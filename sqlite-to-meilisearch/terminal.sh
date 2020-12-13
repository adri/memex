#!/usr/bin/env fish
# Imports commands run from the fish shell

history --show-time='<-SNIP->%s;%F %T;%Y-%m;' \
  | jq --slurp --raw-input --raw-output \
    'split("<-SNIP->") | map(split(";")) |
        map({"id": ("terminal-" + (.[0] + .[3] | @base64 | gsub("=|\\\+|/"; ""))),
             "verb": "commanded",
             "provider": "terminal",
             "timestamp_unix": .[0],
             "timestamp_utc": .[1],
             "date_month": .[2],
             "command": .[3]})' \
   | jq -r '.[]'

