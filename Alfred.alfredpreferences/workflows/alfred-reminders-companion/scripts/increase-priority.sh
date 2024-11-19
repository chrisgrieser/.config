#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables
#───────────────────────────────────────────────────────────────────────────────

current_prio="$priority"
[[ "$current_prio" == "none" ]] && new_prio="low"
[[ "$current_prio" == "low" ]] && new_prio="medium"
[[ "$current_prio" == "medium" ]] && new_prio="high"
[[ "$current_prio" == "high" ]] && new_prio="none"

# HACK since `reminders edit` does not work reliably, we work around it by
# deleting and then re-creating the reminder
reminders delete "$reminder_list" "$id" >&2
if [[ -n "$body" ]]; then # empty body causes error
	reminders add "$reminder_list" --notes="$body" --due-date="today" \
		--priority="$new_prio" -- "$title" >&2
else
	reminders add "$reminder_list" --due-date="today" \
		--priority="$new_prio" -- "$title" >&2
fi
