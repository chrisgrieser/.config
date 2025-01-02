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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	if (!argv[0]) return "No open window";
	let [title, url] = argv[0].split("\t");

	// prevent markdown link from becoming invalid, see https://github.com/chrisgrieser/alfred-read-later/issues/4
	title = title.replace(/\[|\]/g, "").trim();

	const dateSignifier = "📆"; // https://publish.obsidian.md/tasks/Getting+Started/Dates
	const isoDate = new Date().toISOString().slice(0, 10);
	const date = $.getenv("add_date") === "iso8601" ? ` ${dateSignifier} ${isoDate}` : "";

	const mdLinkTask = `- [ ] [${title}](${url})${date}`;

	// append
	const filepath = $.getenv("read_later_file");
	// `readFile` does not fail but only returns empty string if file doesn't exist
	const currentFile = readFile(filepath);
	const newFile = currentFile.trim() + "\n" + mdLinkTask;
	writeToFile(filepath, newFile);

	return title; // for Alfred notification
}
