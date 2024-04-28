#!/usr/bin/env osascript -l JavaScript

// CONFIG
/** @type {Intl.DateTimeFormatOptions} */
const format = { weekday: "short", day: "numeric", month: "long" };
const lang = "en-GB";

//───────────────────────────────────────────────────────────────────────────

/** @param {number} inXDays */
function getDisplayDate(inXDays) {
	const date = new Date();
	date.setDate(date.getDate() + inXDays);
	return date.toLocaleDateString(lang, format);
}

/** @param {"Sunday"|"Monday"|"Tuesday"|"Wednesday"|"Thursday"|"Friday"|"Saturday"} weekday */
function daysUntilNext(weekday) {
	const weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
	const weekdayNum = weekdays.indexOf(weekday);
	const weekdayNumToday = new Date().getDay();
	const daysUntil = (weekdayNum - weekdayNumToday) % 7;
	return daysUntil === 0 ? 7 : daysUntil;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0] || "";

	const dateChoices = [
		{
			title: "Tomorrow",
			subtitle: getDisplayDate(1),
			arg: 1,
		},
		{
			title: "in 2 Days",
			subtitle: getDisplayDate(2),
			arg: 2,
		},
		{
			title: "in 7 days",
			subtitle: getDisplayDate(7),
			arg: 7,
		},
		{
			title: "next Monday",
			subtitle: getDisplayDate(daysUntilNext("Monday")),
			arg: daysUntilNext("Monday"),
		},
		{
			title: "next Tuesday",
			subtitle: getDisplayDate(daysUntilNext("Tuesday")),
			arg: daysUntilNext("Tuesday"),
		},
		{
			title: "next Thursday",
			subtitle: getDisplayDate(daysUntilNext("Thursday")),
			arg: daysUntilNext("Thursday"),
		},
		{
			title: "in 2 weeks",
			subtitle: getDisplayDate(14),
			arg: 14,
		},
	];
	

	return JSON.stringify({
		variables: { reminderText: query },
		items: dateChoices,
	});
}
