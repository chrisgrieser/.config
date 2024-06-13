#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const remTitle = argv[0].trim();
	const list = $.getenv("reminder_list");

	const inDays = $.getenv("inDays");
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + Number.parseInt(inDays));
	const isoDate = dueDate.toISOString().slice(0, 10);

	app.doShellScript(`reminders add "${list}" --due-date="${isoDate}" -- "${remTitle}"`);
	return remTitle; // Alfred notification
}
