#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred vars

layout="$1"
dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"
layout_file="$dock_layout_storage/$layout.plist"

mkdir -p "$dock_layout_storage"
if cp -f "$dock_plist" "$layout_file"; then
	echo -n "✅ New layout saved as \"$layout\""
else
	echo -n "⚠️ Failed to save layout."
fi
