#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

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
	let lineNo = 0;

	const readLaterItems = readFile($.getenv("read_later_file"))
		.trim()
		.split("\n")
		.map((line) => {
			lineNo++;

			// GUARD
			const unreadItem = line.startsWith("- [ ] ");
			const validItem = line.includes("](");
			if (!unreadItem || !validItem) return {};

			const [_, title, url, date] = line.match(
				/- \[ \] \[([^\]]*)\]\((.*?)\) ?(\p{Extended_Pictographic} .*)?/u,
			);
			const dateStr = date ? `${date}  ·  ` : "";
			return {
				title: title,
				subtitle: dateStr + url,
				arg: lineNo,
			};
		});

	// "Add current browser tab" item
	readLaterItems.unshift({ title: "🔖 Add current browser tab", arg: -1, subtitle: "" });

	return JSON.stringify({ items: readLaterItems });
}
