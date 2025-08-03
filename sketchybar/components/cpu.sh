#!/usr/bin/env zsh

# CPU values from `top` more reliable than from `ps` https://stackoverflow.com/questions/30855440/how-to-get-cpu-utilization-in-in-terminal-mac
cpu_usage=$(top -F -n0 -l1 -s0 | grep "^CPU" | awk '{ print int($3 + $5) }')
cpu_fraction=$(echo "scale = 2; $cpu_usage / 100" | bc)

# `--push` adds to graph component https://felixkratz.github.io/SketchyBar/config/components#data-graph----draws-an-arbitrary-graph-into-the-bar
sketchybar --push "$NAME" "$cpu_fraction"

# for pure count, use
# sketchybar--set "$NAME" label="$cpu_usage%"
