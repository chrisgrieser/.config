#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} reminderObj
 * @property {string} title
 * @property {number} priority
 * @property {string} list
 * @property {string} notes
 * @property {string} externalId
 * @property {boolean} isCompleted
 * @property {string} dueDate
 */

const isToday = (/** @type {Date} */ aDate) => {
	const today = new Date();
	return (
		aDate.getDate() === today.getDate() &&
		aDate.getMonth() === today.getMonth() &&
		aDate.getFullYear() === today.getFullYear()
	);
};

//───────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// parameters
	const list = $.getenv("reminder_list");
	const urlRegex =
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/;
	const showCompleted =
		$.NSProcessInfo.processInfo.environment.objectForKey("showCompleted").js === "true";

	// RUN CMD
	// PERF query filters directly for completed reminders
	const completedArg = showCompleted ? "--include-completed" : "";
	const shellCmd = `reminders show "${list}" ${completedArg} --format="json"`;

	const today = new Date();
	today.setHours(23, 59, 59, 0); // to include reminders later that day

	/** @type {reminderObj[]} */
	const responseJson = JSON.parse(app.doShellScript(shellCmd));
	const remindersFiltered = responseJson.filter((rem) => {
		const dueDate = rem.dueDate && new Date(rem.dueDate);
		const noDueDate = rem.dueDate === undefined;
		const openAndDueBeforeToday = !rem.isCompleted && dueDate < today;
		const completedAndDueToday = rem.isCompleted && dueDate && isToday(dueDate);
		return openAndDueBeforeToday || completedAndDueToday || noDueDate;
	});

	/** @type {AlfredItem[]} */
	const reminders = remindersFiltered.map((rem) => {
		const { title, notes, externalId, isCompleted, dueDate } = rem;
		const body = notes || "";
		const displayBody = body.trim().replace(/\n+/g, " · ");
		const content = title + "\n" + body;

		const [url] = content.match(urlRegex) || [];
		let urlSubtitle = url ? "⌘: Open URL" : "⌘: ⛔ No URL";
		if (url && !isCompleted) urlSubtitle += " and mark as completed";
		let emoji = isCompleted ? "☑️ " : "";
		if (!dueDate) emoji += "no 🗓️ "; // indicator for missing due date

		// INFO the boolean are all stringified, so they are available as "true"
		// and "false" after stringification, instead of the less clear "1" and "0"
		/** @type {AlfredItem} */
		const alfredItem = {
			title: emoji + title,
			subtitle: displayBody,
			variables: {
				id: externalId,
				title: title,
				body: body,
				notificationTitle: isCompleted ? "🔲 Uncompleted" : "☑️ Completed",
				mode: isCompleted ? "uncomplete" : "complete",
				isCompleted: isCompleted.toString(), // only used for cmd action
				showCompleted: showCompleted.toString(),
				remindersLeftNow: true.toString(),
				remindersLeftLater: remindersFiltered.length - 1, // for deciding whether to loop back
			},
			// copy via cmd+c
			text: { copy: content },
			mods: {
				// open URL
				cmd: {
					arg: url,
					subtitle: urlSubtitle,
					valid: Boolean(url),
				},
				// edit content
				alt: { arg: content },
				// toggle completed
				ctrl: {
					variables: {
						showCompleted: (!showCompleted).toString(),
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
					title: "No open tasks for today.",
					subtitle: "⏎: Show completed tasks.",
					variables: {
						remindersLeftNow: false.toString(),
						showCompleted: true.toString(),
					},
					mods: { cmd: invalid, shift: invalid, alt: invalid },
				},
			],
		});
	}

	return JSON.stringify({ items: reminders });
}
