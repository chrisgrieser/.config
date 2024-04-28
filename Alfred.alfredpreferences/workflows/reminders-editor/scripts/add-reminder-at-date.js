#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const reminderText = (argv[0] || "").trim();
	const list = $.getenv("reminder_list");

	const inDays = $.getenv("inDays");
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + Number.parseInt(inDays));

	const rem = Application("Reminders");
	const newReminder = rem.Reminder({
		name: reminderText,
		alldayDueDate: dueDate,
	});
	rem.lists.byName(list).reminders.push(newReminder);
	rem.quit();

	return reminderText; // Alfred notification
}
