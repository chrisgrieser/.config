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
		console.log("Cache Dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	/** @type {Intl.DateTimeFormatOptions} */
	const dateFormatOption = { year: "numeric", month: "short", day: "2-digit" };
	const language = $.getenv("lang");
	const resultInBrackets = $.getenv("in_brackets") === "1";
	const addLineBreak = $.getenv("line_break_after") === "1";
	const cacheDir = $.getenv("alfred_workflow_cache");
	ensureCacheFolderExists();

	const dateInput = argv[0];
	let weekCounter;
	let startDate;

	//───────────────────────────────────────────────────────────────────────────

	// date input → set startdate + reset week counter
	if (dateInput) {
		writeToFile(cacheDir + "/startdate", dateInput);
		weekCounter = 0;
		startDate = new Date(dateInput);
	} else {
		weekCounter = parseInt(readFile(cacheDir + "/weekCounter"));
		weekCounter++; // one more week
		startDate = new Date(readFile(cacheDir + "/startDate"));
	}

	// calculate new date
	const dayOne = startDate.getDate(); // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse
	const nextweekDay = dayOne + 7 * weekCounter; // the next weeks date as days from from the StartDate's day

	const nextWeek = startDate; // counts from startdate
	nextWeek.setDate(nextweekDay); // counting from the startDate, update to the new day
	let output = nextWeek.toLocaleDateString(language, dateFormatOption); // format

	// consider state-specific German holidays
	const bundesland = $.getenv("bundesland_feiertage");
	if (bundesland) {
		const url = `https://feiertage-api.de/api/?jahr=${nextWeek.getFullYear()}&nur_land=${bundesland}`;
		const feiertageJSON = JSON.parse(app.doShellScript(`curl -s "${url}"`));
		const feiertage = Object.keys(feiertageJSON).map(function (tag) {
			const isoDate = feiertageJSON[tag].datum;
			const desc = tag + " " + feiertageJSON[tag].hinweis;
			return [isoDate, desc];
		});

		const nextWeekISO = nextWeek.toISOString().slice(0, 10);

		for (const feiertag in feiertage) {
			const feiertagISODate = feiertag[0];
			const desc = feiertag[1];
			if (feiertagISODate === nextWeekISO) output += " " + desc;
		}
	}

	if (resultInBrackets) output = `(${output})`;
	if (addLineBreak) output += "\n";
	return output;
}
