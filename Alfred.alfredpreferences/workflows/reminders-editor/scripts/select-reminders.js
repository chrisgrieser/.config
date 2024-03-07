#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const today = new Date().toISOString().slice(0, 10);
	const list = $.getenv("reminder_list");

	/** @type AlfredItem[] */
	const reminders = JSON.parse(
		app.doShellScript(`reminders show "${list}" --due-date="${today}" --format="json"`),
	).map((/** @type {{ title: string; body: string; externalId: string; }} */ rem) => {
		return {
			title: rem.title,
			subtitle: rem.body,
			arg: rem.externalId,
		};
	});

	// GUARD
	if (reminders.length === 0)
		return JSON.stringify({ items: [{ title: "No reminders for today.", valid: false }] });

	return JSON.stringify({ items: reminders });
}
