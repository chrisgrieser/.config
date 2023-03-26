#!/usr/bin/env osascript -l JavaScript

function run() {
	const sidenotes = Application("Sidenotes");
	const reminders = Application("Reminders");

	const content = sidenotes.currentNote().text();
	sidenotes.currentNote().delete();

	reminders.defaultList().make({ new: "reminder", withProperties: { name: content } });
	// alternative method
	// const newReminder = reminders.Reminder({ name: "Title for reminder", body: "Notes for the reminder" });
	// reminders.lists.byName("List Name").reminders.push(newReminder);

	return content; // direct return for notification
}
