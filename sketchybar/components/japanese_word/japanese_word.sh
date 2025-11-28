#!/usr/bin/env zsh

# CONFIG
location_of_this_file="$(dirname "$0")"
vocab_source="$location_of_this_file/n5.json"

#───────────────────────────────────────────────────────────────────────────────

# get random word
length=$(jq ". | length" "$vocab_source")
# n=$(od -An -N2 -tu2 < /dev/urandom) # more random than $RANDOM
random_num=$((1 + RANDOM % length))
word=$(jq ".[$random_num]" "$vocab_source")

# from word, take the furigana (fallback to word if empty) and meaning
hiragana=$(echo "$word" | jq -r ".furigana")
kanji_or_katakana=$(echo "$word" | jq -r ".word")
english=$(echo "$word" | jq -r ".meaning" | cut -d"," -f1)
japanese=${hiragana:-$kanji_or_katakana}

#───────────────────────────────────────────────────────────────────────────────

sketchybar --set "$NAME" label="$japanese $english"
