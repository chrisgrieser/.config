#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variable

# delete existing reminder
msg=$(reminders delete "$reminder_list" "$id")
echo "❗ $msg" >&2 # log msg in Alfred console

# create new reminder for tomorrow
# using reminders CLI does not allow for alldayDueDate, therefore using JXA version
# PENDING https://github.com/keith/reminders-cli/issues/79
# msg=$(reminders add "$reminder_list" "$title" --notes="$body" --due-date="tomorrow")
osascript -l JavaScript -e "
	const tomorrow = new Date();
	tomorrow.setDate(tomorrow.getDate() + 1);
	const rem = Application('Reminders');
	const newReminder = rem.Reminder({
		name: '$title',
		body: '$body',
		alldayDueDate: tomorrow,
	});
	rem.lists.byName('$reminder_list').reminders.push(newReminder);
	rem.quit();
" &>/dev/null

# pass for notification
echo -n "$title"
