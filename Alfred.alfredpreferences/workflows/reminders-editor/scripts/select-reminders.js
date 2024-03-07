#!/usr/bin/env osascript -l JavaScript
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const endOfToday = new Date();
	endOfToday.setHours(23, 59, 59, 0); // to include reminders in the afternoon
	const remindersToday = Application("Reminders")
		.defaultList()
		.reminders.whose({
			dueDate: { _lessThan: endOfToday },
			completed: false,
		});

	// GUARD
	if (remindersToday.length === 0) {
		return JSON.stringify({ items: [{ title: "No reminders today" }] });
	}

	/** @type AlfredItem[] */
	const items = [];

	// biome-ignore lint/nursery/useForOf: needed due to JXA
	for (let i = 0; i < remindersToday.length; i++) {
		const rem = remindersToday[i];
		const name = rem.name();
		const id = rem.id();
		items.push({
			title: name,
			subtitle: id,
			arg: id,
		});
	}

	return JSON.stringify({ items: items });
}
