#!/usr/bin/env osascript -l JavaScript

// CONFIG
const dateChoices = [
	{ title: "Tomorrow", inDays: 1 },
	{ title: "in 2 days", inDays: 2 },
	{ title: "in 7 days", inDays: 7 },
	{ title: "next Monday", inDays: "Monday" },
	{ title: "next Tuesday", inDays: "Tuesday" },
	{ title: "next Thursday", inDays: "Thursday" },
	{ title: "in 2 weeks", inDays: 14 },
];

/** @type {Intl.DateTimeFormatOptions} */
const format = { weekday: "short", day: "numeric", month: "long" };
const lang = "en-GB";

//───────────────────────────────────────────────────────────────────────────

/** @param {string} weekday */
function daysUntilNext(weekday) {
	const weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
	const weekdayNum = weekdays.indexOf(weekday);
	const weekdayNumToday = new Date().getDay();
	let daysUntil = (weekdayNum - weekdayNumToday) % 7;
	if (daysUntil < 1) daysUntil += 7;
	return daysUntil;
}

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = (argv[0] || "").trim();

	const alfredArray = dateChoices.map(
		(/** @type {AlfredItem&{inDays: number|string}} */ choice) => {
			choice.variables = { selectedDueDate: choice.title }; // label for notification
			choice.valid = Boolean(query); // only valid with query
			const inDays =
				typeof choice.inDays === "number" ? choice.inDays : daysUntilNext(choice.inDays);
			choice.arg = inDays;

			// display date for subtitle
			const date = new Date();
			date.setDate(date.getDate() + inDays);
			choice.subtitle = date.toLocaleDateString(lang, format);

			return choice;
		},
	);

	return JSON.stringify({
		variables: { reminderText: query },
		items: alfredArray,
	});
}
