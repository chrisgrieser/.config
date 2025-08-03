#!/usr/bin/env zsh

# CONFIG
high_threshold=185

#───────────────────────────────────────────────────────────────────────────────

# CPU values from `top` more reliable than from `ps` https://stackoverflow.com/questions/30855440/how-to-get-cpu-utilization-in-in-terminal-mac
cpu_usage=$(top -F -n0 -l1 -s0 | grep "^CPU" | awk '{ print int($3 + $5) }')
cpu_fraction=$(echo "scale = 2; $cpu_usage / 100" | bc)

if defaults read -g AppleInterfaceStyle | grep -q "Dark"; then
	fill_color="0xffcccccc"
	high_color="0xffc95050" # red #c95050
else
	fill_color="0xff444444"
	high_color="0xffc95050" # red
fi

[[ $cpu_usage -gt $high_threshold ]] && fill_color=$high_color

# `--push` adds to graph component https://felixkratz.github.io/SketchyBar/config/components#data-graph----draws-an-arbitrary-graph-into-the-bar
sketchybar \
	--push "$NAME" "$cpu_fraction" \
	--set "$NAME" graph.fill_color="$fill_color"

# for pure count, use
# sketchybar--set "$NAME" label="$cpu_usage%"
