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

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const alfredArray = dateChoices.map(
		(/** @type {AlfredItem&{inDays: number|string}} */ choice) => {
			const inDays =
				typeof choice.inDays === "number" ? choice.inDays : daysUntilNext(choice.inDays);

			// display date for subtitle
			const date = new Date();
			date.setDate(date.getDate() + inDays);
			choice.subtitle = "🗓️ " + date.toLocaleDateString(lang, {
				weekday: "short",
				day: "numeric",
				month: "long",
			});

			choice.variables = {
				selectedDate: choice.title, // label for Alfred
				inDays: inDays, // used as argument in next script
			};

			choice.arg = ""; // empty for next keyword input
			return choice;
		},
	);

	return JSON.stringify({ items: alfredArray });
}
