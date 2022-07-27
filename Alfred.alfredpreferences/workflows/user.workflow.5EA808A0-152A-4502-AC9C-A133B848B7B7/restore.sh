#!/usr/bin/env zsh
hash=$(echo "$*" | cut d";" -f1)
FULL_PATH=$(echo "$*" | cut d";" -f2)

dir="$(dirname "$FULL_PATH")"
file="$(basename "$FULL_PATH")"

cd "$dir" || exit 1
git checkout "$hash" -- "$file"

open "$file"
