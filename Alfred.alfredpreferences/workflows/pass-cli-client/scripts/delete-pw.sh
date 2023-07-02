#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

pass delete "$*" &>/dev/null
echo -n "$*" # Alfred Notification
