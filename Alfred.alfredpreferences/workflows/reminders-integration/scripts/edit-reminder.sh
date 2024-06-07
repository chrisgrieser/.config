#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
#───────────────────────────────────────────────────────────────────────────────

title=$(echo "$*" | head -n1)
body=$(echo "$*" | tail -n +2)

# HACK since `reminders edit` does not work reliably
msg()reminders delete "$reminder_list" "$id"

reminders add "$reminder_list" "$title" --notes="$body" --due-date="today"

echo "$*" | pbcopy # bkp
echo -n "Updated $title"
