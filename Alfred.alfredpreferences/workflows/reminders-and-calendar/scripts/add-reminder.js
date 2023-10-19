#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const inDays = parseInt(argv[0])
	console.log("🪚 inDays:", inDays);
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + inDays);
	console.log("🪚 dueDate:", dueDate);

	const text = $.getenv("reminderText");
	const title = text.split("\n")[0];
	const body = text.split("\n").slice(1).join("\n");

	const rem = Application("Reminders");
	const newReminder = rem.Reminder({
		name: title,
		body: body,
		allDayDueDate: (new Date()),
	});
	rem.defaultList().reminders.push(newReminder)

	rem.quit()
	return title; // Alfred notification
}
