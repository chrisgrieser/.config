#!/usr/bin/env bash

date=$(date +'%a %e. %b %H:%M')

# blinking ":"
# INFO got spaces from https://aresluna.org/spaces/ for exact width as ":" in
# non-monospace font
(($(date +'%s') % 2 == 1)) && date="${date//:/  }"

apple=""


sketchybar --set "$NAME" label="$date"
