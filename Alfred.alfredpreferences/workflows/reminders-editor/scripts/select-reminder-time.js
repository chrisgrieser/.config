#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const today = new Date();
	const weekdayNum = today.getDay();

	const daysUntilMonday = weekdayNum === 1 ? 7 : (1 - weekdayNum + 7) % 7;
	const daysUntilWedday = weekdayNum === 3 ? 7 : (3 - weekdayNum + 7) % 7;
	const daysUntilSunday = weekdayNum === 0 ? 7 : 7 - weekdayNum;

	const query = argv[0];

	const jsonArray = [
		{
			title: "Tomorrow",
			variables: { selectedDueDate: "Tomorrow" }, // label for notification
			arg: 1,
		},
		{
			title: "In 2 Days",
			variables: { selectedDueDate: "In 2 Days" },
			arg: 2,
		},
		{
			title: "In 7 days",
			variables: { selectedDueDate: "In 7 days" },
			arg: 7,
		},
		{
			title: "Next Monday",
			variables: { selectedDueDate: "Next Monday" },
			arg: daysUntilMonday,
		},
		{
			title: "Next Wednesday",
			variables: { selectedDueDate: "Next Wednesday" },
			arg: daysUntilWedday,
		},
		{
			title: "Next Sunday",
			variables: { selectedDueDate: "Next Sunday" },
			arg: daysUntilSunday,
		},
		{
			title: "In 2 weeks",
			variables: { selectedDueDate: "In 2 weeks" },
			arg: 14,
		},
	];

	return JSON.stringify({
		variables: { reminderText: query },
		items: jsonArray,
	});
}
