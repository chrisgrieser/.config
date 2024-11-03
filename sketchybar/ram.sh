#!/usr/bin/env zsh

# CONFIG
# icons=("󰄰" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")
icons=("󰋙" "󰫃" "󰫄" "󰫅" "󰫆" "󰫇" "󰫈")

#───────────────────────────────────────────────────────────────────────────────

memory_free=$(memory_pressure | tail -n1 | grep --only-matching '[0-9.]*')
memory_usage=$((100 - memory_free))
idx=$((${#icons} * memory_usage / 100 + 1)) # shell division is always rounded down
[[ $idx -gt ${#icons} ]] && idx=${#icons} # only needed for 100%

sketchybar --set "$NAME" icon="${icons[$idx]}"
