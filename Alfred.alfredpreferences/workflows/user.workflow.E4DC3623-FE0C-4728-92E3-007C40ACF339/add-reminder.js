#!/usr/bin/env osascript -l JavaScript
function run(argv) {

	const today = new Date();
	const weekdayNum = today.getDay();
	const daysUntilMonday = (7 - weekdayNum).toString;
	const daysUntilSunday = (6 - weekdayNum).toString;
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
			title: "In 3 Days",
			arg: "3",
		},
		{
			title: "Next Monday",
			arg: daysUntilMonday,
		},
		{
			title: "Next Sunday",
			arg: daysUntilSunday,
		},
	];

	return JSON.stringify({
		variables: { eventText: query },
		items: jsonArray,
	});
}
