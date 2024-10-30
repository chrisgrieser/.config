#!/usr/bin/env zsh

cpu_usage=$(top -F -n0 -l1 -s0 | grep "^CPU" | awk '{ print int($3 + $5) }')
cpu_fraction=$(echo "scale = 2; $cpu_usage / 100" | bc)



sketchybar --set "$NAME" label="$cpu_usage%" \
	--push "$NAME" "$cpu_fraction"
