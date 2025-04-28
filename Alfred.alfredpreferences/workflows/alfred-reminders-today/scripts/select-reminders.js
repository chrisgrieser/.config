#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} ReminderObj
 * @property {string} id
 * @property {string} title
 * @property {string?} notes aka body
 * @property {string} list
 * @property {string} listColor
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
 * @property {string} calendarColor
 * @property {string} startTime
 * @property {string} endTime
 * @property {boolean} isAllDay
 * @property {string?} location
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

// must accept any letters before the colon to match video call URIs for events
const urlRegex =
	/\w{3,}:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=?/&]{1,256}?\.[a-zA-Z0-9()]{1,7}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)/;

/** @type {Intl.DateTimeFormatOptions} */
const timeFmt = { hour: "2-digit", minute: "2-digit", hour12: false };

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheAgeThresholdMins = Number.parseInt($.getenv("event_cache_duration_hours")) * 60;
	const cacheObj = Application("System Events").aliases[path];
	ensureCacheFolderExists();
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (Date.now() - +cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThresholdMins;
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

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

	const swiftReminderOutput = app.doShellScript("./scripts/get-reminders.swift");
	let /** @type {ReminderObj[]} */ remindersJson;
	try {
		remindersJson = JSON.parse(swiftReminderOutput);
	} catch (_error) {
		const errmsg = swiftReminderOutput; // if not parsable, it's a message
		console.log(errmsg);
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

	/** @type {AlfredItem[]} */
	// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
	const reminders = remindersFiltered.map((rem) => {
		const body = rem.notes || "";
		const content = (rem.title + "\n" + body).trim();
		const [url] = content.match(urlRegex) || [];

		// SUBTITLE: display due time, past & missing due dates, list, and notes
		const dueDateObj = new Date(rem.dueDate);
		const dueTime = rem.isAllDay ? "" : new Date(rem.dueDate).toLocaleTimeString([], timeFmt);
		const pastDueDate = dueDateObj < startOfToday ? relativeDate(dueDateObj) : "";
		const missingDueDate = rem.dueDate ? "" : "no due date";
		const listName = includeAllLists ? rem.listColor + " " + rem.list : "";
		const subtitle = [
			rem.hasRecurrenceRules ? "🔁" : "",
			"❗️".repeat(rem.priority), // white exclamation mark not visible in many themes
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
					variables: { showCompleted: (!showCompleted).toString() },
				},
			},
		};
		return alfredItem;
	});
	console.log("Reminders:", reminders.length);

	// GUARD no reminders
	if (reminders.length === 0) {
		const invalid = { valid: false, subtitle: "⛔ No reminders" };
		reminders.push({
			title: `No ${showCompleted ? "" : "open "}reminders for today.`,
			subtitle: `⌃⏎: Show ${showCompleted ? "only open" : "completed"} reminders`,
			valid: false,
			mods: {
				cmd: invalid,
				shift: invalid,
				alt: invalid,
				fn: invalid,
				ctrl: { variables: { showCompleted: true.toString() }, valid: true },
			},
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	// EVENTS
	let /** @type {AlfredItem[]} */ events = [];
	const eventCachePath = $.getenv("alfred_workflow_cache") + "/events.json";
	const cacheOutdated = showEvents && cacheIsOutdated(eventCachePath);

	if (showEvents && cacheOutdated) {
		console.log("Writing new cache for events…");

		let /** @type {EventObj[]} */ eventsJson;
		const swiftEventsOutput = app.doShellScript("./scripts/get-events-today.swift");
		try {
			eventsJson = JSON.parse(swiftEventsOutput);
		} catch (_error) {
			const errmsg = swiftEventsOutput; // if not parsable, it's a message
			return JSON.stringify({ items: [{ title: errmsg, valid: false }] });
		}

		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
		events = eventsJson.map((event) => {
			// time
			let timeDisplay = "";
			if (!event.isAllDay) {
				const start = event.startTime
					? new Date(event.startTime).toLocaleTimeString([], timeFmt)
					: "";
				const end = event.endTime
					? new Date(event.endTime).toLocaleTimeString([], timeFmt)
					: "";
				timeDisplay = start + " – " + end;
			}

			// location
			const maxLen = 40;
			const url = event.location?.match(urlRegex);
			const icon = url ? "🌐" : "📍";
			let locationDisplay = event.location?.replaceAll("\n", " ") || "";
			if (locationDisplay.length > maxLen)
				locationDisplay = locationDisplay.slice(0, maxLen) + "…";
			locationDisplay = event.location ? `${icon} ${locationDisplay}` : "";
			const openUrl = url || "https://www.google.com/maps/search/" + event.location;

			const subtitle = [
				event.hasRecurrenceRules ? "🔁" : "",
				timeDisplay,
				locationDisplay,
				event.calendarColor + " " + event.calendar,
			]
				.filter(Boolean)
				.join("    ");

			const invalid = { valid: false, subtitle: "⛔ Not available for events." };
			return {
				title: event.title,
				subtitle: subtitle,
				icon: { path: "./calendar.png" },
				mods: { cmd: invalid, shift: invalid, alt: invalid, fn: invalid, ctrl: invalid },

				valid: Boolean(event.location), // only actionable if there is a location
				arg: openUrl,
				variables: { mode: "open-event" },
			};
		});
		writeToFile(eventCachePath, JSON.stringify(events));
	} else if (showEvents && !cacheOutdated) {
		events = JSON.parse(readFile(eventCachePath));
	}
	console.log("Events:", showEvents ? events.length : "not shown");

	//───────────────────────────────────────────────────────────────────────────

	// OUTPUT
	return JSON.stringify({
		items: [...reminders, ...events],
		skipknowledge: true, // keep sorting order

		// PERF cache only used for loose reload, however there is a hard-coded
		// minimum of 5 seconds, so every workflow action will trigger a cache
		// deletion https://www.alfredforum.com/topic/23042-alfred-script-filter-caching-appears-to-have-a-hard-coded-minimum-of-5-seconds/
		// -> the performance benefit is only for when the user peeks at the
		// reminders without actioning them.
		cache: { seconds: 0, loosereload: true },
	});
}
