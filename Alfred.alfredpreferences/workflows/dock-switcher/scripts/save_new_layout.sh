#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred vars

layout="$1"
dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"
layout_file="$dock_layout_storage/$layout.plist"

cp -f "$dock_plist" "$layout_file"
echo -n "✅ New layout saved as \"$layout\""
