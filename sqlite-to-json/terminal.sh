#!/usr/bin/env fish
# Imports commands run from the fish shell

history --show-time='<-SNIP->%s-;-%F %T-;-%Y-%m-;-' \
  | sed '0,/^<-SNIP->/s///' \
  | jq --slurp --raw-input --raw-output \
    'split("<-SNIP->")
        | map(split("-;-"))
        | map(select(.[0]!=null))
        | map({"id": ("terminal-" + ((.[0] + .[3] | @base64 | gsub("=|\\\+|/"; "")) | .[-246:])),
             "verb": "commanded",
             "provider": "terminal",
             "timestamp_unix": .[0]|tonumber,
             "timestamp_utc": .[1],
             "date_month": .[2],
             "command": .[3]})' \
   | jq -r -c '. | unique_by(.id) | .[]'

