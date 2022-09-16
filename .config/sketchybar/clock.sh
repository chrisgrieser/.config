#!/usr/bin/env sh


date=$(date +'%a %e. %b %H:%M')

# blinking ":"
# got spaces from https://aresluna.org/spaces/ for exact width as ":" in
# non-monospace font
(( $(date +'%s') % 2 == 1 )) && date="${date/:/  }"

sketchybar --set "$NAME" label="$date"


