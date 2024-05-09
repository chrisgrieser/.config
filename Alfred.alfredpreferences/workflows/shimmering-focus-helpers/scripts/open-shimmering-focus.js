#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const alfredMatcher = (/** @type {string} */ str) =>
	str.replace(/[-()_:.]/g, " ") + " " + str + " ";

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sfPath = $.getenv("local_repos") + "/shimmering-focus/theme.css";

	//───────────────────────────────────────────────────────────────────────────
	// REPO NEEDS TO BE CLONED

	if (!fileExists(sfPath)) {
		const branch = $.getenv("branch_to_use");
		return JSON.stringify({
			items: [
				{
					title: "Clone the Repo",
					subtitle: `Branch: ${branch}`,
					arg: "clone",
				},
			],
		});
	}

	//───────────────────────────────────────────────────────────────────────────
	// SELECT NAVIGATION MARKER

	let lineNum = 0;
	const navigationMarkers = readFile(sfPath)
		.split("\n")
		.reduce((/** @type {AlfredItem[]} */ acc, line) => {
			lineNum++;

			// GUARD line is not marker
			if (!line.startsWith("/* <") && !line.startsWith("  - # <<")) return acc;

			const name = line
				.replace(/ \*\/$/, "") // comment-ending
				.replace(/^\/\* *<+ ?/, "") // comment-beginning
				.replace(/^ {2}- # ?<+ ?/, ""); // YAML-comment

			name.toString
			acc.push({
				title: name,
				subtitle: lineNum.toString(),
				match: alfredMatcher(name),
				uid: name, // not lineNum, since the lineNum can change
				arg: lineNum,
			});
			return acc;
		}, []);

	return JSON.stringify({ items: navigationMarkers });
}
