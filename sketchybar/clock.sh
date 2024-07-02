#!/usr/bin/env zsh
# date=$(date +'%a %e. %b %H:%M')
date=$(date +'%a %H:%M' | cut -c1-2,4-) # shorter, since day & month are displayed via busycal icon

# blinking ":"
# INFO got using punctuation space from https://aresluna.org/spaces/ for exact
# width as ":" in non-monospace font
(($(date +'%s') % 2 == 1)) && date="${date//:/ }"

sketchybar --set "$NAME" label="$date"
