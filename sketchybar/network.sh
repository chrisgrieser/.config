#!/usr/bin/env zsh



#!/usr/bin/env bash

pkill -f "netstat -w5"
netstat -w5 \
  | awk '/[0-9]/ {print $3/5 "," $6/5; fflush(stdout)}' \
  | xargs -I {} bash -c "sketchybar --trigger netstat_update DOWNLOAD=\$(cut -d, -f1 <<< {}) UPLOAD=\$(cut -d, -f2 <<< {})" &

sketchybar --set "$NAME" label="$network_usage%"
