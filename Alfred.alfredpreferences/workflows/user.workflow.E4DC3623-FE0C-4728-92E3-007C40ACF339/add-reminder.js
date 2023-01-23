#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	const today = new Date();
	const weekdayNum = today.getDay();

	const daysUntilMonday = weekdayNum === 1 ? 7 : (8 - weekdayNum) % 7;
	const daysUntilWedday = weekdayNum === 3 ? 7 : (10 - weekdayNum) % 7;
	const daysUntilSunday = weekdayNum === 0 ? 7 : 7 - weekdayNum;

	const query = argv[0];

	const jsonArray = [
		{
			title: "Tomorrow",
			arg: 1,
		},
		{
			title: "In 2 Days",
			arg: 2,
		},
		{
			title: "In 7 days",
			arg: 7,
		},
		{
			title: "Next Monday",
			arg: daysUntilMonday,
		},
		{
			title: "Next Wednesday",
			arg: daysUntilWedday,
		},
		{
			title: "Next Sunday",
			arg: daysUntilSunday,
		},
		{
			title: "In 2 weeks",
			arg: 14,
		},
	];

	return JSON.stringify({
		variables: { eventText: query },
		items: jsonArray,
	});
}
