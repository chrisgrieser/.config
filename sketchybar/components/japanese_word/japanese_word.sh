#!/usr/bin/env zsh

# CONFIG
location_of_this_file="$(dirname "$0")"
vocab_source="$location_of_this_file/n5.json"
output="hiragana" # romaji|hiragana

#-------------------------------------------------------------------------------

# get random word
length=$(jq ". | length" "$vocab_source")
random_num=$(($(od -An -N2 -tu2 < /dev/urandom) % length)) # more random than $RANDOM
# random_num=$((1 + RANDOM % length))
word=$(jq ".[$random_num]" "$vocab_source")

# from word, take the furigana (fallback to word if empty) and meaning
if [[ $output == "romaji" ]]; then
	romaji=$(echo "$word" | jq -r ".romaji" | sed 's_ / _/_g')
	japanese="$romaji:"
else
	hiragana=$(echo "$word" | jq -r ".furigana")
	kanji_or_katakana=$(echo "$word" | jq -r ".word")
	japanese=${hiragana:-$kanji_or_katakana}
fi
english=$(echo "$word" | jq -r ".meaning" | cut -d"," -f1)

sketchybar --set "$NAME" label="$japanese $english"
