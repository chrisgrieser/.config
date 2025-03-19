#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} reminderObj
 * @property {string} title
 * @property {0|1|5|9} priority 0 = None, 9 = Low, 5 = Medium, 1 = High
 * @property {string} list
 * @property {string} notes
 * @property {string} externalId
 * @property {boolean} isCompleted
 * @property {string} dueDate
 * @property {string} startDate
 */

const isToday = (/** @type {Date} */ aDate) => {
	const today = new Date();
	return today.toDateString() === aDate.toDateString();
};

const isAllDayReminder = (/** @type {Date} */ dueDate) => {
	return dueDate.getHours() === 0 && dueDate.getMinutes() === 0;
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
	/(https?|obsidian):\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=?/&]{1,256}?\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)/;

//───────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// parameters
	const list = $.getenv("reminder_list");
	const showCompleted =
		$.NSProcessInfo.processInfo.environment.objectForKey("showCompleted").js === "true";

	// RUN CMD
	// INFO not filtering for reminders due today, since the filtering should
	// include reminders with due date in the past or with missing due date.
	const completedArg = showCompleted ? "--include-completed" : "";
	const shellCmd = `reminders show "${list}" ${completedArg} --sort=due-date --format=json`;

	const endOfToday = new Date();
	endOfToday.setHours(23, 59, 59, 0); // to include reminders later that day
	/** @type {reminderObj[]} */
	const responseJson = JSON.parse(app.doShellScript(shellCmd));
	const remindersFiltered = responseJson.filter((rem) => {
		const dueDate = rem.dueDate && new Date(rem.dueDate);
		const noDueDate = rem.dueDate === undefined;
		const openAndDueBeforeToday = !rem.isCompleted && dueDate < endOfToday;
		const completedAndDueToday = rem.isCompleted && dueDate && isToday(dueDate);
		return openAndDueBeforeToday || completedAndDueToday || noDueDate;
	});

	const remindersLeftLater = remindersFiltered.length - 1;
	const startOfToday = new Date();
	startOfToday.setHours(0, 0, 0, 0);

	/** @type {AlfredItem[]} */
	const reminders = remindersFiltered.map((rem) => {
		const { title, notes, externalId, isCompleted, dueDate } = rem;
		const body = notes || "";
		const content = title + "\n" + body;
		const dueDateObj = new Date(dueDate);

		// SUBTITLE: display due time, past due dates, missing due dates, and body
		const dueTime =
			!isAllDayReminder(dueDateObj) &&
			new Date(dueDate).toLocaleTimeString([], {
				hour: "2-digit",
				minute: "2-digit",
				hour12: false,
			});
		const pastDueDate =
			dueDateObj < startOfToday && relativeDate(dueDateObj)
		const missingDueDate = !dueDate && "no due date";
		const subtitle = [body.replace(/\n+/g, " "), dueTime || pastDueDate || missingDueDate]
			.filter(Boolean)
			.join(" · ");

		const [url] = content.match(urlRegex) || [];
		const emoji = isCompleted ? "☑️ " : "";

		// INFO the boolean are all stringified, so they are available as "true"
		// and "false" after stringification, instead of the less clear "1" and "0"
		/** @type {AlfredItem} */
		const alfredItem = {
			title: emoji + title,
			subtitle: subtitle,
			text: { copy: content, largetype: content },
			variables: {
				id: externalId,
				title: title,
				body: body,
				notificationTitle: isCompleted ? "🔲 Uncompleted" : "☑️ Completed",
				mode: isCompleted ? "uncomplete" : "complete",
				cmdMode: url ? "open-url" : "copy", // only for `cmd`
				isCompleted: isCompleted.toString(), // only for `cmd`
				showCompleted: showCompleted.toString(),
				remindersLeftNow: true.toString(),
				remindersLeftLater: remindersLeftLater, // for deciding whether to loop back
			},
			mods: {
				// open URL/copy
				cmd: {
					arg: url || content,
					subtitle:
						(url ? "⌘: Open URL" : "⌘: Copy") + (isCompleted ? "" : " and mark as completed"),
				},
				// edit content
				alt: {
					arg: content,
				},
				// toggle completed
				ctrl: {
					variables: { showCompleted: (!showCompleted).toString() },
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

	return JSON.stringify({
		items: reminders,
		skipknowledge: true, // keep sorting order
	});
}
