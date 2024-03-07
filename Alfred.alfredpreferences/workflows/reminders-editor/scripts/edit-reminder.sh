#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variable




msg=$(reminders edit "$reminder_list" "$id" "$title" --notes "$body")
echo "❗ $msg" >&2 # log msg in ALfred console

echo -n "$title" # pass for notification

reminders edit Default 1173144E-EF1C-4C52-BC50-9FDBC686B78F "hello world" --notes "ffffff"
