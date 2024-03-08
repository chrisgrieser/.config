#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const inDays = Number.parseInt(argv[0] || "0");
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + inDays);

	const reminderText = $.getenv("reminderText").trim().replace(/^#+ ?/, "");
	const lines = reminderText.split("\n");
	const title = lines.shift();
	const body = lines.join("\n");

	const rem = Application("Reminders");
	const list = $.getenv("reminder_list");

	const newReminder = rem.Reminder({
		name: title || "Untitled",
		body: body,
		alldayDueDate: dueDate,
	});
	rem.lists.byName(list).reminders.push(newReminder);
	rem.quit();

	return title; // Alfred notification
}
