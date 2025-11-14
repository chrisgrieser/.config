#!/usr/bin/env zsh

test_site="www.google.com"
draw=$(curl --fail --max-time 3 "$test_site" && echo "false" || echo "true")
sketchybar --set "$NAME" drawing="$draw"
