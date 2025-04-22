#!/usr/bin/env zsh
date=$(date +'%a %e. %b %H:%M:%S')

# blinking ":"
# INFO got using punctuation space from https://aresluna.org/spaces/ for exact
# width as ":" in non-monospace font
(($(date +'%s') % 2 == 1)) && date="${date//:/ }"

sketchybar --set "$NAME" label="$date"
