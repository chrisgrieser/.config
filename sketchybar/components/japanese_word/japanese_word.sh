#!/usr/bin/env zsh

# CONFIG
location_of_this_file="$(dirname "$0")"
vocab_source="$location_of_this_file/n5.json"

#───────────────────────────────────────────────────────────────────────────────

length=$(jq ". | length" "$vocab_source")
random_num=$((1 + RANDOM % length))

# from random word, take the furigana (fallback to word if empty) and meaning
hiragana=$(jq -r ".[$random_num].furigana" "$vocab_source")
kanji_or_katakana=$(jq -r ".[$random_num].word" "$vocab_source")
english=$(jq -r ".[$random_num].meaning" "$vocab_source")
japanese=${hiragana:-$kanji_or_katakana}

#───────────────────────────────────────────────────────────────────────────────

sketchybar --set "$NAME" label="$japanese $english"
