#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];

	const dateFormat = {
		weekday: "short",
		day: "numeric",
		month: "short",
	};
	const lang = "en-US";
	//───────────────────────────────────────────────────────────────────────────

	const today = new Date();

	const tomorrow = new Date();
	tomorrow.setDate(tomorrow.getDate() + 1);
	const in2Days = new Date()
	tomorrow.setDate(tomorrow.getDate() + 2);

	const weekdayNum = today.getDay();
	const daysUntilMonday = weekdayNum === 1 ? 7 : (1 - weekdayNum + 7) % 7;
	const daysUntilWednesday = weekdayNum === 3 ? 7 : (3 - weekdayNum + 7) % 7;
	const daysUntilSunday = weekdayNum === 0 ? 7 : 7 - weekdayNum;

	const jsonArray = [
		{
			title: "Tomorrow",
			subtitle: tomorrow.toDateString(),
			variables: { selectedDueDate: "Tomorrow" }, // label for notification
			arg: 1,
		},
		{
			title: "in 2 Days",
			variables: { selectedDueDate: "in 2 Days" },
			arg: 2,
		},
		{
			title: "in 7 days",
			variables: { selectedDueDate: "in 7 days" },
			arg: 7,
		},
		{
			title: "next Monday",
			variables: { selectedDueDate: "next Monday" },
			arg: daysUntilMonday,
		},
		{
			title: "next Wednesday",
			variables: { selectedDueDate: "next Wednesday" },
			arg: daysUntilWednesday,
		},
		{
			title: "next Sunday",
			variables: { selectedDueDate: "next Sunday" },
			arg: daysUntilSunday,
		},
		{
			title: "in 2 weeks",
			variables: { selectedDueDate: "in 2 weeks" },
			arg: 14,
		},
	];

	return JSON.stringify({
		variables: { reminderText: query },
		items: jsonArray,
	});
}
