#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variable

# delete existing reminder
msg=$(reminders delete "$reminder_list" "$id")
echo "❗ $msg" >&2 # log msg in ALfred console

# create new reminder for tomorrow
msg=$(reminders add "$reminder_list" "$title" --notes "$body" --due-date="tomorrow")
echo "❗ $msg" >&2 # log msg in ALfred console

# pass for notification
echo -n "$title"
