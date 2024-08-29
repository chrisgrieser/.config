#!/usr/bin/env zsh

entry="$*"
pass delete "$entry" &>/dev/null
echo "$entry" # Alfred Notification
