#!/usr/bin/env zsh

# - INFO `upload` would be $6
# - HACK `netstat` only allows streaming output, we use `awk`'s `exit` to
# - return the first value.
download_kb=$(netstat -w1 | awk '/[0-9]/ {print int($3/1024) ; exit }')

sketchybar --set "$NAME" label="${download_kb}󰬒"
