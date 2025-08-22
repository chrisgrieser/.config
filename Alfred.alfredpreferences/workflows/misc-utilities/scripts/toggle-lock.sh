#!/usr/bin/env zsh

filepath="$1"

# Get only the flags field from ls -lO
# shellcheck disable=2012
flags=$(ls -lO "$filepath" | awk '{print $5}')
name=$(basename "$filepath")

if [[ "$flags" == *"uchg"* ]]; then
	chflags -h nouchg "$filepath"
	alfred_msg="🔒 Unlocked $name"
else
	chflags -h uchg "$filepath"
	alfred_msg="🔓Locked $name"
fi

echo "$alfred_msg"
