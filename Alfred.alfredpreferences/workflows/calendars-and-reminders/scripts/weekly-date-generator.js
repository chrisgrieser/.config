#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const language = $.getenv("date_locale");
	const resultInBrackets = $.getenv("in_brackets") === "1";
	const addLineBreak = $.getenv("line_break_after") === "1";
	const germanState = $.getenv("bundesland_feiertage");

	/** @type {Intl.DateTimeFormatOptions} */
	const dateFormatOption = { year: "numeric", month: "short", day: "2-digit" };
	const cacheDir = $.getenv("alfred_workflow_cache");
	const dateInput = argv[0];
	let weekCounter;
	let startDate;

	//───────────────────────────────────────────────────────────────────────────

	// date input → set startdate + reset week counter
	if (dateInput) {
		startDate = new Date(dateInput);
		weekCounter = 0;

		ensureCacheFolderExists();
		writeToFile(cacheDir + "/startDate", dateInput);
		writeToFile(cacheDir + "/weekCounter", weekCounter.toString());
	} else {
		if (!fileExists(cacheDir + "/startDate") || !fileExists(cacheDir + "/weekCounter")) {
			return "No start-date found. Initialize with Alfred keyword `weekly`.";
		}

		startDate = new Date(readFile(cacheDir + "/startDate"));
		weekCounter = Number.parseInt(readFile(cacheDir + "/weekCounter")) + 1;
		writeToFile(cacheDir + "/weekCounter", weekCounter.toString());
	}

	// calculate new date
	const dayOnNextWeek = startDate.getDate() + weekCounter * 7; // next week's date as days from startDate
	const nextDate = startDate; // counts from startdate
	nextDate.setDate(dayOnNextWeek); // counting from startDate, update to new day
	let output = nextDate.toLocaleDateString(language, dateFormatOption);

	// consider state-specific German holidays
	if (germanState) {
		const nextDateIso = new Date(nextDate.getTime() - nextDate.getTimezoneOffset() * 60_000)
			.toISOString()
			.slice(0, 10);
		const url = `https://feiertage-api.de/api/?jahr=${nextDate.getFullYear()}&nur_land=${germanState}`;
		const holidayJson = JSON.parse(httpRequest(url));
		for (const [name, holiday] of Object.entries(holidayJson)) {
			if (holiday.datum === nextDateIso) output += ` ${name} ${holiday.hinweis}`.trimEnd();
		}
	}

	// output
	if (resultInBrackets) output = `(${output})`;
	if (addLineBreak) output += "\n";
	return output;
}
