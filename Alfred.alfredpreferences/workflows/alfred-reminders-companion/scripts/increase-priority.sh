#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables
#───────────────────────────────────────────────────────────────────────────────

# HACK since `reminders edit` does not work reliably, we work around it by
# deleting and then re-creating the reminder
reminders delete "$reminder_list" "$id" >&2
if [[ -n "$body" ]]; then # empty body causes error
	reminders add "$reminder_list" --notes="$body" --due-date="tomorrow" \
		--priority="$priority" -- "$title" >&2
else
	reminders add "$reminder_list" --due-date="tomorrow" \
		--priority="$priority" -- "$title" >&2
fi

echo -n "$title" # pass for notification
