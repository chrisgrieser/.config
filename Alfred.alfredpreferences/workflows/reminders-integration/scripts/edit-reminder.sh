#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
#───────────────────────────────────────────────────────────────────────────────

title=$(echo "$*" | head -n1)
body=$(echo "$*" | tail -n +2)

# HACK since `reminders edit` does not work reliably, we work around it by
# deleting and then re-creating the reminder

#───────────────────────────────────────────────────────────────────────────────

reminders delete "$reminder_list" "$id" &> /dev/null
if [[ -n "$body" ]]; then # empty body causes error
	reminders add "$reminder_list" "$title" --notes="$body" --due-date="today" &> /dev/null
else
	reminders add "$reminder_list" "$title" --due-date="today" &> /dev/null
fi

echo -n "$title" # pass for notification
