#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	const today = new Date();
	const weekdayNum = today.getDay();
	const daysUntilMonday = (7 - weekdayNum).toString();
	const daysUntilSunday = (7 - weekdayNum).toString();
	const daysUntilWednesday = (6 - weekdayNum).toString();
	const query = argv[0];

	const jsonArray = [
		{
			title: "Tomorrow",
			arg: "1",
		},
		{
			title: "In 2 Days",
			arg: "2",
		},
		{
			title: "In 7 days",
			arg: "7",
		},
		{
			title: "Next Monday",
			arg: daysUntilMonday,
		},
		{
			title: "Next Wednesday",
			arg: daysUntilWednesday,
		},
		{
			title: "Next Sunday",
			arg: daysUntilSunday,
		},
		{
			title: "In 2 weeks",
			arg: "14",
		},
	];

	return JSON.stringify({
		variables: { eventText: query },
		items: jsonArray,
	});
}
