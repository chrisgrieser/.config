#!/usr/bin/env osascript -l JavaScript

/** @param {string[]} argv */
	// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function run(argv) {
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
	const jsonArray = [];

	//───────────────────────────────────────────────────────────────────────────

	const LOCAL_REPOS = argv[0];
	const sfPath = LOCAL_REPOS + "/shimmering-focus/source.css";
	if (!fileExists(sfPath)) {
		jsonArray.push({
			title: "Clone the Repo",
			arg: "clone",
		});
		jsonArray.push({
			title: "Switch to Fallback",
			arg: "fallback",
		});
		return JSON.stringify({ items: jsonArray });
	}

	//───────────────────────────────────────────────────────────────────────────

	let i = 0;
	const navigationMarkers = readFile(sfPath)
		.split("\n")
		.map((line) => {
			i++;
			return { content: line, ln: i };
		})
		.filter((line) => line.content.startsWith("/* <") || line.content.startsWith("# <<"));

	navigationMarkers.forEach((marker) => {
		const name = marker.content
			.replace(/ \*\/$/, "") // comment-ending syntax
			.replace(/^\/\* *<+ ?/, "") // comment-beginning syntax
			.replace(/^# ?<+ ?/, ""); // YAML-comment syntax

		jsonArray.push({
			title: name,
			subtitle: marker.ln,
			match: alfredMatcher(name),
			uid: name,
			arg: marker.ln,
		});
	});

	return JSON.stringify({ items: jsonArray });
}
