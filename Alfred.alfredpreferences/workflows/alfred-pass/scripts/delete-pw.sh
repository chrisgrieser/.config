#!/usr/bin/env zsh

pass delete "$*" &>/dev/null
# shellcheck disable=2154
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
echo -n "$*" # Alfred Notification
