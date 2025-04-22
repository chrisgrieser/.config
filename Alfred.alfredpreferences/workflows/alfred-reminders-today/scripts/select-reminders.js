#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} Reminder
 * @property {string} id
 * @property {string} title
 * @property {string?} notes aka body
 * @property {string} list
 * @property {boolean} isCompleted
 * @property {string} dueDate
 * @property {string} creationDate
 * @property {boolean} isAllDay
 * @property {boolean} hasRecurrenceRules
 * @property {number} priority
 */

/** @typedef {Object} EventObj
 * @property {string} title
 * @property {string} calendar
 * @property {string} startTime
 * @property {string} endTime
 * @property {boolean} isAllDay
 * @property {string} location
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
	const deltaMins = (Date.now() - +absDate) / 1000 / 60;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"} */
	let unit;
	let delta;
	if (deltaMins < 60) {
		unit = "minute";
		delta = Math.floor(deltaMins);
	} else if (deltaMins < 60 * 24) {
		unit = "hour";
		delta = Math.floor(deltaMins / 60);
	} else if (deltaMins < 60 * 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaMins / 60 / 24);
	} else if (deltaMins < 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaMins / 60 / 24 / 7);
	} else if (deltaMins < 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	return formatter.format(-delta, unit);
}

const urlRegex =
	/(https?|obsidian):\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=?/&]{1,256}?\.[a-zA-Z0-9()]{1,7}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)/;

/** @type {Intl.DateTimeFormatOptions} */
const timeFmt = { hour: "2-digit", minute: "2-digit", hour12: false };

//───────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const showCompleted =
		$.NSProcessInfo.processInfo.environment.objectForKey("showCompleted").js === "true";
	const includeNoDuedate = $.getenv("include_no_duedate") === "1";
	const includeAllLists = $.getenv("include_all_lists") === "1";
	const showEvents = $.getenv("show_events") === "1";

	//───────────────────────────────────────────────────────────────────────────

	// REMINDERS
	const startOfToday = new Date();
	startOfToday.setHours(0, 0, 0, 0);
	const endOfToday = new Date();
	endOfToday.setHours(23, 59, 59, 0); // to include reminders later that day

	const swiftReminderOutput = app.doShellScript("swift ./scripts/get-reminders.swift");
	let /** @type {Reminder[]} */ remindersJson;
	try {
		remindersJson = JSON.parse(swiftReminderOutput);
	} catch (_error) {
		const errmsg = "❌ " + swiftReminderOutput; // if not parsable, it's a message
		return JSON.stringify({ items: [{ title: errmsg, valid: false }] });
	}

	const remindersFiltered = remindersJson
		.filter((rem) => {
			const dueDate = rem.dueDate ? new Date(rem.dueDate) : null;
			const openNoDueDate = includeNoDuedate && !rem.dueDate && !rem.isCompleted;
			const openAndDueBeforeToday = dueDate && !rem.isCompleted && dueDate < endOfToday;
			const completedAndDueToday = showCompleted && rem.isCompleted && isToday(dueDate);
			return openAndDueBeforeToday || completedAndDueToday || openNoDueDate;
		})
		.sort((a, b) => {
			// 1. by priority, 2. by due date, 3. by creation date
			const prioDiff = b.priority - a.priority;
			if (prioDiff !== 0) return prioDiff;
			const dueTimeDiff = +new Date(a.dueDate) - +new Date(b.dueDate);
			if (dueTimeDiff !== 0) return dueTimeDiff;
			return +new Date(a.creationDate) - +new Date(b.creationDate);
		});
	console.log("Filtered reminders:", JSON.stringify(remindersFiltered, null, 2));

	/** @type {AlfredItem[]} */
	// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
	const reminders = remindersFiltered.map((rem) => {
		const body = rem.notes || "";
		const content = (rem.title + "\n" + body).trim();
		const [url] = content.match(urlRegex) || [];

		// SUBTITLE: display due time, past due dates, missing due dates, list (if
		// multiple), and body
		const dueDateObj = new Date(rem.dueDate);
		const dueTime = rem.isAllDay ? "" : new Date(rem.dueDate).toLocaleTimeString([], timeFmt);
		const pastDueDate = dueDateObj < startOfToday ? relativeDate(dueDateObj) : "";
		const missingDueDate = rem.dueDate ? "" : "no due date";
		const listName = includeAllLists ? rem.list : ""; // only display when more than 1
		const subtitle = [
			rem.hasRecurrenceRules ? "🔁" : "",
			"!".repeat(rem.priority),
			listName,
			dueTime || pastDueDate || missingDueDate,
			body.replace(/\n+/g, " "),
		]
			.filter(Boolean)
			.join("  ·  ");

		const emoji = rem.isCompleted ? "☑️ " : "";

		// INFO the boolean are all stringified, so they are available as "true"
		// and "false" after stringification, instead of the less clear "1" and "0"
		/** @type {AlfredItem} */
		const alfredItem = {
			title: emoji + rem.title,
			subtitle: subtitle,
			text: { copy: content, largetype: content },
			quicklookurl: url,
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
				alt: {
					arg: content,
					variables: { id: rem.id, mode: "edit-reminder" },
				},
				shift: {
					variables: { id: rem.id, title: rem.title, mode: "snooze" },
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

	// GUARD no reminders
	if (reminders.length === 0) {
		const invalid = { valid: false, subtitle: "⛔ No reminders" };
		reminders.push({
			title: "No open tasks for today.",
			subtitle: "⏎: Show completed tasks.",
			variables: { showCompleted: true.toString(), mode: "show-completed" },
			mods: { cmd: invalid, shift: invalid, alt: invalid, fn: invalid },
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	// EVENTS
	let events = [];

	if (showEvents) {
	const swiftEventsOutput = app.doShellScript("swift ./scripts/events-today.swift");
	let /** @type {EventObj[]} */ eventsJson;
	try {
		eventsJson = JSON.parse(swiftEventsOutput);
	} catch (_error) {
		const errmsg = "❌ " + swiftEventsOutput; // if not parsable, it's a message
		return JSON.stringify({ items: [{ title: errmsg, valid: false }] });
	}

	events = eventsJson.map((event) => {
		let time = "";
		if (!event.isAllDay) {
			const start = event.startTime
				? new Date(event.startTime).toLocaleTimeString([], timeFmt)
				: "";
			const end = event.endTime ? new Date(event.endTime).toLocaleTimeString([], timeFmt) : "";
			time = start + " – " + end;
		}

		const subtitle = [
			event.hasRecurrenceRules ? "🔁" : "",
			time,
			event.location ? "📍 " + event.location : "",
			"📅 " + event.calendar,
		]
			.filter(Boolean)
			.join("   ");

		return {
			title: event.title,
			subtitle: subtitle,
			valid: false, // read-only
		};
	});
	}

	//───────────────────────────────────────────────────────────────────────────

	// OUTPUT
	return JSON.stringify({
		items: [...reminders, ...events],
		skipknowledge: true, // keep sorting order
	});
}
