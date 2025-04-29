#!/usr/bin/env zsh

isodate=$(date +%Y-%m-%d)
isotime=$(date +%H:%M)
query="$1"

# shellcheck disable=2154 # Alfred env var
echo "$isotime – $query" >> "$search_log_folder/$isodate.log"
