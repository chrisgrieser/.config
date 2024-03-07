#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const list = $.getenv("reminder_list");

	/** @type AlfredItem[] */
	const reminders = JSON.parse(
		app.doShellScript(`reminders show "${list}" --due-date="today" --format="json"`),
	).map((/** @type {{ title: string; notes: string; externalId: string; }} */ rem) => {
		const { title, notes, externalId } = rem;
		const displayBody = (notes || "").trim().replace(/\n+/g, " · ");
		return {
			title: title,
			subtitle: displayBody,
			variables: {
				id: externalId,
				title: title,
				notes: notes,
			},
			// edit
			mods: {
				cmd: { arg: title + "\n" + notes },
			},
		};
	});

	// GUARD
	if (reminders.length === 0) {
		return JSON.stringify({ items: [{ title: "No reminders for today.", valid: false }] });
	}

	return JSON.stringify({ items: reminders });
}
