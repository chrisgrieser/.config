#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type {AlfredItem[]} */
	const readLaterItems = readFile($.getenv("read_later_file"))
		.trim()
		.split("\n")
		.filter((line) => line.startsWith("- [ ] "))
		.map((line) => {
			const valid = line.includes("](");
			if (!valid) {
				return {
					title: "Line does not have valid markdown task syntax:",
					valid: false,
					subtitle: line,
				};
			}
			const title = line.split("](")[0].slice(7);
			const url = line.split("](")[1].slice(0, -1);
			return {
				title: title,
				subtitle: url,
				arg: url,
			};
		});

	// "Add current browser tab" item
	readLaterItems.unshift({ title: "🔖 Add current browser tab", arg: "add" });

	return JSON.stringify({ items: readLaterItems });
}
