#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

pass delete "$*" &>/dev/null
# shellcheck disable=2154
[[ "$auto_push" -eq 1 ]] && pass git push &>/dev/null
echo -n "$*" # Alfred Notification
