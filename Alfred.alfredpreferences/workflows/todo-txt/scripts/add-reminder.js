#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const inDays = parseInt(argv[0])
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + inDays);

	const reminderText = $.getenv("reminderText").trim().replace(/^#+ ?/, "");
	const lines = reminderText.split("\n");
	const title = lines.shift();
	const body = lines.join("\n");

	const rem = Application("Reminders");

	const newReminder = rem.Reminder({
		name: title,
		body: body,
		alldayDueDate: dueDate,
	});
	rem.defaultList().reminders.push(newReminder)

	rem.quit()
	return title; // Alfred notification
}
