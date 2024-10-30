#!/usr/bin/env zsh

# CONFIG
threshold_kb=50

#───────────────────────────────────────────────────────────────────────────────

# HACK `netstat` only streams stdout, so using exiting `awk` to return 1st value
network=$(netstat -w1 | awk '/[0-9]/ {print int($3/1024) "," int($6/1024) ; exit }')
download_kb=$(echo "$network" | cut -d',' -f1)
upload_kb=$(echo "$network" | cut -d',' -f2)

download=$download_kb
upload=$upload_kb
download_unit="k"
upload_unit="k"

# GUARD only show when above threshold
if [[ $download -lt $threshold_kb && $upload -lt $threshold_kb ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# Formatting
if [[ $download -gt 1024 ]]; then
	download=$(echo "scale = 1; $download / 1024" | bc)
	download_unit="M"
fi
if [[ $upload -gt 1024 ]]; then
	upload=$(echo "scale = 1; $upload / 1024" | bc)
	upload_unit="M"
fi
[[ $download_kb -ge $threshold_kb ]] && download_display="⏷${download}${download_unit}"
[[ $upload_kb -ge $threshold_kb ]] && upload_display="⏶${upload}${upload_unit}"
[[ $upload_kb -ge $threshold_kb && $download_kb -ge $threshold_kb ]] && sep="  "

# Display
sketchybar --set "$NAME" label="$download_display$sep$upload_display" drawing=true
