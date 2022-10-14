#!/usr/bin/env osascript -l JavaScript
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat

function run (argv) {
	ObjC.import("stdlib");
	ObjC.import("Foundation");

	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function onlineJSON (url) {
		return JSON.parse (app.doShellScript('curl -s "' + url + '"'));
	}

	function readData (key) {
		const fileExists = (filePath) => Application("Finder").exists(Path(filePath));
		const dataPath = $.getenv("alfred_workflow_data") + key;
		if (!fileExists(dataPath)) return "data does not exist.";
		const data = $.NSFileManager.defaultManager.contentsAtPath(dataPath);
		const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
		return ObjC.unwrap(str);
	}

	function writeData (key, newValue) {
		const dataPath = $.getenv("alfred_workflow_data") + key;
		const str = $.NSString.alloc.initWithUTF8String(newValue);
		str.writeToFileAtomicallyEncodingError(dataPath, true, $.NSUTF8StringEncoding, null);
	}

	//──────────────────────────────────────────────────────────────────────────────

	const dateFormatOption = { year: "numeric", month: "short", day: "2-digit" };
	const language = $.getenv("lang");
	const resultInBrackets = $.getenv("in_brackets") === "1";
	const addLineBreak = $.getenv("line_break_after") === "1";

	const dateInput = argv.join("");
	let weekCounter;
	let startDate;

	// MAIN
	//──────────────────────────────────────────────────────────────────────────────

	// date input → set startdate + reset week counter
	if (dateInput) {
		writeData ("startdate", dateInput);
		weekCounter = 0;
		startDate = new Date(dateInput);
	} else {
		weekCounter = parseInt(readData("week_no"));
		weekCounter++;
		startDate = new Date(readData("startdate"));
	}
	writeData ("week_no", weekCounter.toString()); // set week counter for next run

	// calculate new date
	const dayOne = startDate.getDate(); // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse
	const nextweekDay = dayOne + 7*weekCounter; // the next weeks date as days from from the StartDate's day

	const nextWeek = startDate; // counts from startdate
	nextWeek.setDate(nextweekDay); // counting from the startDate, update to the new day
	let output = nextWeek.toLocaleDateString(language, dateFormatOption); // format

	// consider state-specific German holidays
	const bundesland = $.getenv("bundesland_feiertage");
	if (bundesland) {
		const url =
			"https://feiertage-api.de/api/?jahr="
			+ nextWeek.getFullYear()
			+ "&nur_land="
			+ bundesland;
		const feiertageJSON = onlineJSON(url);
		const feiertage = Object.keys(feiertageJSON).map (function (tag) {
			const isoDate = feiertageJSON[tag].datum;
			const desc = tag + " " + feiertageJSON[tag].hinweis;
			return [isoDate, desc];
		});

		const nextWeekISO = nextWeek.toISOString().slice(0, 10);
		feiertage.forEach(feiertag => {
			const feiertagISODate = feiertag[0];
			const desc = feiertag[1];
			if (feiertagISODate === nextWeekISO) output += " " + desc;
		});
	}

	if (resultInBrackets) output = "(" + output + ")";
	if (addLineBreak) output += "\n";
	return output;
}

