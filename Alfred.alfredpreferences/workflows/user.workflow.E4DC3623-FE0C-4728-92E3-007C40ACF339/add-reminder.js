#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	//──────────────────────────────────────────────────────────────────────────────

	const today = new Date();
	const day = today.getDay();
	const daysUntilMonday = 7 - day;
	const daysUntilSunday = 6 - day;
	// const query = argv[0];

	console.log("Number of days until next Monday: " + daysUntilMonday);

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

	return JSON.stringify({ items: jsonArray });
}
