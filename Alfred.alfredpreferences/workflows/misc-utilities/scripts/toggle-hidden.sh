#!/usr/bin/env zsh

filepath="$1"

# Get only the flags field from `ls -lO`
# shellcheck disable=2012
flags=$(ls -lO "$filepath" | awk '{print $5}')
name=$(basename "$filepath")

if [[ "$flags" == *"hidden"* ]]; then
	chflags -h nohidden "$filepath"
	alfred_msg="👀 Unhide \"$name\""
else
	chflags -h hidden "$filepath"
	alfred_msg="👀 Hide \"$name\""
fi

echo "$alfred_msg"
