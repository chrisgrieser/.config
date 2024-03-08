#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const list = $.getenv("reminder_list");
	const urlRegex =
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/;

	/** @type AlfredItem[] */
	const reminders = JSON.parse(
		app.doShellScript(`reminders show "${list}" --due-date="today" --format="json"`),
	).map((/** @type {{ title: string; notes: string; externalId: string; }} */ rem) => {
		const { title, notes, externalId } = rem;
		const body = notes || "";
		const displayBody = body.trim().replace(/\n+/g, " · ");
		const content = title + "\n" + body;

		const [url] = content.match(urlRegex) || [];
		let urlSubtitle = url ? "⌘: Open URL and mark as complete" : "⌘: ⛔ No URL";
		// only show URL if not already in the title to avoid duplicaation
		const urlInTitle = title.match(urlRegex);
		if (url && !urlInTitle) urlSubtitle += "  ·  " + url;

		return {
			title: title,
			subtitle: displayBody,
			variables: {
				id: externalId,
				title: title,
				notes: body,
			},
			text: { copy: content },
			mods: {
				cmd: {
					arg: url,
					subtitle: urlSubtitle,
					valid: Boolean(url),
				},
				alt: { arg: content }, // edit content
			},
		};
	});

	// GUARD
	if (reminders.length === 0) {
		return JSON.stringify({ items: [{ title: "No reminders for today.", valid: false }] });
	}

	return JSON.stringify({ items: reminders });
}
