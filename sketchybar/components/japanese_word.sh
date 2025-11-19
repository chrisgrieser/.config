#!/usr/bin/env zsh
vocab_source="$HOME/Documents/Japanisch/N5 Vocab/n5.json"

length=$(jq ". | length" "$vocab_source")
random_num=$((1 + RANDOM % length))
display=$(jq -r ".[$random_num] | .furigana + \" \" + .meaning" "$vocab_source")

#───────────────────────────────────────────────────────────────────────────────

sketchybar --set "$NAME" label="$display"
