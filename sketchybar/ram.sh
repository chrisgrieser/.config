#!/usr/bin/env zsh

# CONFIG
icons=("󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")

#───────────────────────────────────────────────────────────────────────────────

memory_free=$(memory_pressure | tail -n1 | grep --only-matching '[0-9.]*')
memory_usage=$((100 - memory_free))
idx=$((${#icons} * memory_usage / 100))

sketchybar --set "$NAME" icon="${icons[$idx]}" drawing=true
