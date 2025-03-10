#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables
#───────────────────────────────────────────────────────────────────────────────

# HACK since `reminders edit` does not work reliably, we work around it by
# deleting and then re-creating the reminder
reminders delete "$reminder_list" "$id" >&2
if [[ -n "$body" ]]; then # empty body causes error
	reminders add "$reminder_list" --notes="$body" --due-date="tomorrow" -- "$title" >&2
else
	reminders add "$reminder_list" --due-date="tomorrow" -- "$title" >&2
fi

echo -n "$title" # pass for notification

#───────────────────────────────────────────────────────────────────────────────
# JXA for adding a reminder (not used since slower)

# osascript -l JavaScript -e "
# 	const tomorrow = new ;
# 	tomorrow.setDate(tomorrow.getDate() + 1);
# 	const rem = Application('Reminders');
# 	const newReminder = rem.Reminder({
# 		name: '$title',
# 		body: '$body',
# 		alldayDueDate: tomorrow,
# 	});
# 	rem.lists.byName('$reminder_list').reminders.push(newReminder);
# 	rem.quit();
# " &> /dev/null
