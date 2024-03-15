#!/usr/bin/env zsh

title=$(echo "$*" | head -n1)
echo "❗ title: $title" >&2
body=$(echo "$*" | tail -n +2)
echo "❗ body: $body" >&2

# shellcheck disable=2154 # Alfred variables
msg=$(reminders edit "$reminder_list" "$id" "$title" --notes "$body")
echo "$msg" >&2 # log msg in ALfred console

echo -n "$title" # pass for notification
