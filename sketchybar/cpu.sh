#!/usr/bin/env zsh

cpu_usage=$(top -F -n0 -l1 -s0 | grep "^CPU" | awk '{ print int($3 + $5) }')

sketchybar --set "$NAME" label="$cpu_usage%"
