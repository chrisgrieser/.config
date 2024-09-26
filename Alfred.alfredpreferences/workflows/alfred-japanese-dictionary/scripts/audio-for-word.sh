#!/usr/bin/env zsh

word=$1
voice="Kyoko" # apparently the only Japanese voice on macOS
# shellcheck disable=2154 # alfred var
rate="$audio_speed" # default is apparently 175 https://apple.stackexchange.com/questions/96808/what-is-the-default-speaking-rate-for-the-speech-synthesis-program

say --voice="$voice" --rate="$rate" "$word" &
