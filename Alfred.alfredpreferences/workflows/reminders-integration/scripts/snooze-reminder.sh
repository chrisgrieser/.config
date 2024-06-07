#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

reminders delete "$reminder_list" "$id"
reminders add "$reminder_list" "$title" --notes="$body" --due-date="tomorrow"
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
