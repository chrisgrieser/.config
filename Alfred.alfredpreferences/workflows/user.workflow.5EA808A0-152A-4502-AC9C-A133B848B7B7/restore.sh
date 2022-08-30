#!/usr/bin/env zsh
hash=$(echo "$*" | cut -d";" -f1)
FULL_PATH=$(echo "$*" | cut -d";" -f2)

dir="$(dirname "$FULL_PATH")"
file="$(basename "$FULL_PATH")"
cd "$dir" || exit 1

# backup old version, in case not commited
git add "$FULL_PATH"
git commit -m "Backup of $file" --author="🤖💾<version-history@alfred-workflow.com>"

# restore & open old version
git checkout "$hash" -- "$file"
git commit -m "Restored $file (from $hash)"  --author="🤖❇️<version-history@alfred-workflow.com>"
open "$file"
