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
		$.NSProcessInfo.processInfo.environment.objectForKey("show_completed").js === "true";

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
		const urlSubtitle = url ? "⌘: Open URL and mark as complete" : "⌘: ⛔ No URL";
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
				remindersLeft: responseJson.length - 1, // for deciding whether to loop back
			},
			text: { copy: content },
			mods: {
				cmd: {
					// open URL
					arg: url,
					subtitle: urlSubtitle,
					valid: Boolean(url),
				},
				alt: { arg: content }, // edit content
				ctrl: {
					// toggle completed
					arg: showCompleted ? "false" : "true",
				},
			},
		};
		return alfredItem;
	});

	// GUARD
	if (reminders.length === 0) {
		return JSON.stringify({ items: [{ title: "No reminders for today.", valid: false }] });
	}

	return JSON.stringify({ items: reminders });
}
