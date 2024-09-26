#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

reminders "$mode" "$reminder_list" "$id" &> /dev/null

echo -n "$title" # pass for notification
