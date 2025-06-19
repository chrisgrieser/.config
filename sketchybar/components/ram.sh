#!/usr/bin/env zsh

# CONFIG
icons=("󰋙" "󰫃" "󰫄" "󰫅" "󰫆" "󰫇" "󰫈")
# icons=("󰄰" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")

#───────────────────────────────────────────────────────────────────────────────

memory_free=$(memory_pressure | tail -n1 | grep --only-matching '[0-9.]*')
memory_usage=$((100 - memory_free))

# We need to round up since shell arrays start at 1, but shell divisions always
# round down. Thus adding `+ 1`.
idx=$((${#icons} * memory_usage / 100 + 1))
[[ $idx -gt ${#icons} ]] && idx=${#icons} # only needed for 100%

sketchybar --set "$NAME" icon="${icons[$idx]}" drawing=true
