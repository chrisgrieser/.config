#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} reminderObj
 * @property {string} title
 * @property {string} notes
 * @property {string} externalId
 * @property {boolean} isCompleted
 */

//───────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// parameters
	const list = $.getenv("reminder_list");
	const urlRegex =
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/;
	const showCompleted =
		$.NSProcessInfo.processInfo.environment.objectForKey("showCompleted").js === "true";

	// run cmd
	const completedArg = showCompleted ? "--include-completed" : "";
	const shellCmd = `reminders show "${list}" --due-date="today" ${completedArg} --format="json"`;
	/** @type {reminderObj[]} */
	const responseJson = JSON.parse(app.doShellScript(shellCmd));

	/** @type {AlfredItem[]} */
	const reminders = responseJson.map((rem) => {
		const { title, notes, externalId, isCompleted } = rem;
		const body = notes || "";
		const displayBody = body.trim().replace(/\n+/g, " · ");
		const content = title + "\n" + body;

		const [url] = content.match(urlRegex) || [];
		let urlSubtitle = url ? "⌘: Open URL" : "⌘: ⛔ No URL";
		if (url && !isCompleted) urlSubtitle += " and mark as completed";
		const emoji = isCompleted ? "☑️ " : "";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: emoji + title,
			subtitle: displayBody,
			variables: {
				id: externalId,
				title: title,
				body: body,
				mode: isCompleted ? "uncomplete" : "complete",
				notificationTitle: isCompleted ? "🔲 Uncompleted" : "☑️ Completed",
				remindersLeftLater: responseJson.length - 1, // for deciding whether to loop back
				remindersLeftNow: "true",
			},
			// copy via cmd+c
			text: { copy: content },
			mods: {
				// open URL
				cmd: {
					arg: url,
					subtitle: urlSubtitle,
					valid: Boolean(url),
					variables: {
						isCompleted: isCompleted ? "true" : "false",
					},
				},
				// edit content
				alt: { arg: content },
				// toggle completed
				ctrl: {
					variables: {
						showCompleted: showCompleted ? "false" : "true",
					},
				},
			},
		};
		return alfredItem;
	});

	// GUARD
	if (reminders.length === 0) {
		const invalid = { valid: false, subtitle: "⛔ No reminders" };
		return JSON.stringify({
			items: [
				{
					title: "No reminders for today.",
					subtitle: "⏎: Show completed tasks.",
					variables: {
						remindersLeftNow: "false",
						showCompleted: "true",
					},
					mods: { cmd: invalid, shift: invalid, alt: invalid },
				},
			],
		});
	}

	return JSON.stringify({ items: reminders });
}
