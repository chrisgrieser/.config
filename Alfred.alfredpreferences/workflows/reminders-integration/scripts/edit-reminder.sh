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

msg=$(reminders delete "$reminder_list" "$id")
echo "msg: $msg" >&2

if [[ -n "$body" ]] ; then # empty body causes error
	msg=$(reminders add "$reminder_list" "$title" --notes="$body" --due-date="today")
else
	msg=$(reminders add "$reminder_list" "$title" --due-date="today")
fi
echo "msg: $msg" >&2

#───────────────────────────────────────────────────────────────────────────────

echo -n "$title" # pass for notification
