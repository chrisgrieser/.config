#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const today = new Date().toISOString().slice(0, 10);
	const list = $.getenv("reminder_list");

	// index for usage with the reminder CLI not saved in the json
	let index = 0;

	/** @type AlfredItem[] */
	const reminders = JSON.parse(
		app.doShellScript(`reminders show "${list}" --due-date="${today}" --format="json"`),
	).map((/** @type {{ title: string; notes: string; externalId: string; }} */ rem) => {
		index++;
		const { title, notes } = rem;
		return {
			title: title,
			subtitle: notes.trim(),
			arg: title + notes,
			mods: {
				cmd: { arg: index }, // complete
			},
		};
	});

	// GUARD
	if (reminders.length === 0)
		return JSON.stringify({ items: [{ title: "No reminders for today.", valid: false }] });

	return JSON.stringify({ items: reminders });
}
