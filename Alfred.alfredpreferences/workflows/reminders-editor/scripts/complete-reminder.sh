#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variable

msg=$(reminders complete "$reminder_list" "$id")
echo "❗ $msg" >&2 # log msg in ALfred console

echo -n "$title" # pass for notification
