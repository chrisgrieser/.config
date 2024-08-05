#!/usr/bin/env osascript -l JavaScript

// CONFIG
const dateChoices = [
	{ title: "Tomorrow", inDays: 1 },
	{ title: "in 2 days", inDays: 2 },
	{ title: "in 7 days", inDays: 7 },
	{ title: "next Monday", inDays: "Mon" },
	{ title: "next Tuesday", inDays: "Tue" },
	{ title: "next Thursday", inDays: "Thu" },
	{ title: "in 2 weeks", inDays: 14 },
];

/** @type {Intl.DateTimeFormatOptions} */
const dateFormat = {
	weekday: "short",
	day: "numeric",
	month: "short",
};
const lang = "en-GB";

//───────────────────────────────────────────────────────────────────────────

/** @param {string} weekday */
function daysUntilNext(weekday) {
	const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	const weekdayNum = weekdays.indexOf(weekday);
	const weekdayNumToday = new Date().getDay();
	let daysUntil = (weekdayNum - weekdayNumToday) % 7;
	if (daysUntil < 1) daysUntil += 7;
	return daysUntil;
}

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0].trim();

	const alfredArray = dateChoices.map(
		(/** @type {AlfredItem&{inDays: number|string}} */ choice) => {
			const inDays =
				typeof choice.inDays === "number" ? choice.inDays : daysUntilNext(choice.inDays);

			// display date for subtitle
			const date = new Date();
			date.setDate(date.getDate() + inDays);
			choice.subtitle = "🗓️ " + date.toLocaleDateString(lang, dateFormat);

			const isFirstItem = dateChoices[0].title === choice.title;
			if (isFirstItem) choice.title += `: "${query || "…"}"`;

			choice.variables = {
				selectedDate: choice.title, // label for Alfred
				inDays: inDays, // used as argument in next script
				reminderTitle: query,
			};
			choice.valid = query !== "";
			return choice;
		},
	);

	return JSON.stringify({ items: alfredArray });
}
