#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} reminderObj
 * @property {string} id
 * @property {string} title
 * @property {string?} notes aka body
 * @property {string?} url
 * @property {string} list
 * @property {boolean} isCompleted
 * @property {string} dueDate
 * @property {string} creationDate
 * @property {string} isAllDay
 * @property {boolean} hasRecurrenceRules
 */

const isToday = (/** @type {Date?} */ aDate) => {
	if (!aDate) return false;
	const today = new Date();
	return today.toDateString() === aDate.toDateString();
};

/**
 * @param {Date} absDate
 * @return {string} relative date
 */
function relativeDate(absDate) {
	const deltaSecs = (Date.now() - +absDate) / 1000;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"|"second"} */
	let unit;
	let delta;
	if (deltaSecs < 60) {
		unit = "second";
		delta = deltaSecs;
	} else if (deltaSecs < 60 * 60) {
		unit = "minute";
		delta = Math.ceil(deltaSecs / 60);
	} else if (deltaSecs < 60 * 60 * 24) {
		unit = "hour";
		delta = Math.ceil(deltaSecs / 60 / 60);
	} else if (deltaSecs < 60 * 60 * 24 * 7) {
		unit = "day";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	return formatter.format(-delta, unit);
}

const urlRegex =
	/(https?|obsidian):\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=?/&]{1,256}?\.[a-zA-Z0-9()]{1,7}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)/;

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const showCompleted =
		$.NSProcessInfo.processInfo.environment.objectForKey("showCompleted").js === "true";
	const includeNoDuedate = $.getenv("include_no_duedate") === "1";
	const includeAllLists = $.getenv("include_all_lists") === "1";
	const endOfToday = new Date();
	endOfToday.setHours(23, 59, 59, 0); // to include reminders later that day
	const startOfToday = new Date();
	startOfToday.setHours(0, 0, 0, 0);

	/** @type {reminderObj[]} */
	const remindersJson = JSON.parse(argv[0]);
	const remindersFiltered = remindersJson
		.filter((rem) => {
			const dueDate = rem.dueDate ? new Date(rem.dueDate) : null;
			const openNoDueDate = includeNoDuedate && rem.dueDate === undefined && !rem.isCompleted;
			const openAndDueBeforeToday = dueDate && !rem.isCompleted && dueDate < endOfToday;
			const completedAndDueToday = showCompleted && rem.isCompleted && isToday(dueDate);
			return openAndDueBeforeToday || completedAndDueToday || openNoDueDate;
		})
		.sort((a, b) => +new Date(a.creationDate) - +new Date(b.creationDate));
	console.log("Filtered reminders:", JSON.stringify(remindersFiltered, null, 2));

	/** @type {AlfredItem[]} */
	// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
	const reminders = remindersFiltered.map((rem) => {
		const body = rem.notes || "";
		const content = (rem.title + "\n" + body).trim();
		const [url] = rem.url || content.match(urlRegex) || [];

		// SUBTITLE: display due time, past due dates, missing due dates, list (if
		// multiple), and body
		const dueDateObj = new Date(rem.dueDate);
		/** @type {Intl.DateTimeFormatOptions} */
		const timeFormat = { hour: "2-digit", minute: "2-digit", hour12: false };
		const dueTime = rem.isAllDay ? "" : new Date(rem.dueDate).toLocaleTimeString([], timeFormat);
		const pastDueDate = dueDateObj < startOfToday ? relativeDate(dueDateObj) : "";
		const missingDueDate = rem.dueDate ? "" : "no due date";
		const listName = includeAllLists ? rem.list : ""; // only display when more than 1
		const subtitle = [
			listName,
			dueTime || pastDueDate || missingDueDate,
			body.replace(/\n+/g, " "),
		]
			.filter(Boolean)
			.join("  ·  ");

		let emoji = rem.isCompleted ? "☑️ " : "";
		if (rem.hasRecurrenceRules) emoji += "🔁 ";

		// INFO the boolean are all stringified, so they are available as "true"
		// and "false" after stringification, instead of the less clear "1" and "0"
		/** @type {AlfredItem} */
		const alfredItem = {
			title: emoji + rem.title,
			subtitle: subtitle,
			text: { copy: content, largetype: content },
			variables: {
				id: rem.id,
				title: rem.title,
				notificationTitle: rem.isCompleted ? "🔲 Uncompleted" : "☑️ Completed",
				showCompleted: showCompleted.toString(), // keep "show completed" state
				keepOpen: (remindersFiltered.length > 1).toString(),
				mode: "toggle-completed",
			},
			mods: {
				cmd: {
					arg: url || content,
					subtitle:
						(url ? "⌘: Open URL" : "⌘: Copy") + (rem.isCompleted ? "" : " and complete"),
					variables: {
						id: rem.id,
						title: rem.title,
						cmdMode: url ? "open-url" : "copy",
						mode: rem.isCompleted ? "stop-after" : "toggle-completed",
						keepOpen: false.toString(),
						notificationTitle:
							(url ? "🔗 Open URL" : "📋 Copy") + (rem.isCompleted ? "" : " and completed"),
					},
				},
				alt : {
					arg: content,
					variables: {
						mode: "edit-reminder",
					}
				},
				shift: {
					variables: {
						id: rem.id,
						title: rem.title,
						mode: "snooze",
					},
				},
				ctrl: {
					variables: {
						showCompleted: (!showCompleted).toString(), // toggle "show completed" state
						mode: "show-completed",
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
						showCompleted: true.toString(),
						mode: "show-completed",
					},
					mods: { cmd: invalid, shift: invalid },
				},
			],
		});
	}

	return JSON.stringify({
		items: reminders,
		skipknowledge: true, // keep sorting order
	});
}
