#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variable

msg=$(reminders "$mode" "$reminder_list" "$id")
echo "$msg" >&2 # log msg in Alfred console
echo -n "$title" # pass for notification
