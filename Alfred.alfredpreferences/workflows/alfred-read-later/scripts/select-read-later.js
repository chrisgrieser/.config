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

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const randomItemOrder = $.getenv("randomize_item_order") === "1";

	const readLaterItems = readFile($.getenv("read_later_file"))
		.trim()
		.split("\n")
		.map((line, lineNo) => {
			// GUARD
			const unreadItem = line.startsWith("- [ ] ");
			const validItem = line.includes("](");
			if (!(unreadItem && validItem)) return {};

			const [_, title, url, date] =
				line.match(/- \[ \] \[([^\]]*)\]\((.*?)\) ?(\p{Extended_Pictographic} .*)?/u) || [];
			const dateStr = date ? `${date}  ·  ` : "";

			/** @type {AlfredItem} */
			const item = {
				title: title,
				match: alfredMatcher(title) + alfredMatcher(url),
				subtitle: dateStr + url,
				arg: lineNo + 1,
				quicklookurl: url,
				variables: { mode: "open" },
				mods: {
					cmd: {
						variables: { mode: "mark-as-read" },
					},
				},
			};
			return item;
		});

	if (randomItemOrder) readLaterItems.sort(() => 0.5 - Math.random());

	// "Add current browser tab" item
	readLaterItems.unshift({
		title: "🔖 Add current browser tab",
		subtitle: "",
		variables: { mode: "add" },
		mods: {
			cmd: { valid: false, subtitle: "❌ Not possible." },
		},
	});

	return JSON.stringify({ items: readLaterItems });
}
