#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_:.]/g, " ") + " " + str + " ";
const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//───────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function run(argv) {
	const localRepos = argv[0];
	const sfPath = localRepos + "/shimmering-focus/source.css";

	// GUARD Repo needs to be cloned
	if (!fileExists(sfPath)) {
		return JSON.stringify({
			items: [{ title: "Clone the Repo", arg: "clone" }],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	let lineNum = 0;
	const navigationMarkers = readFile(sfPath)
		.split("\n")
		.map((line) => {
			lineNum++;

			// GUARD line is not marker
			if (!(line.startsWith("/* <") || line.startsWith("  - # <<"))) return {};

			const name = line
				.replace(/ \*\/$/, "") // comment-ending
				.replace(/^\/\* *<+ ?/, "") // comment-beginning
				.replace(/^ {2}- # ?<+ ?/, ""); // YAML-comment

			return {
				title: name,
				subtitle: lineNum,
				match: alfredMatcher(name),
				uid: name, // not lineNum, since the lineNum can change
				arg: lineNum,
			};
		});

	return JSON.stringify({ items: navigationMarkers });
}
