#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

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
	const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g

	/** @type AlfredItem[] */
	const todos = readFile($.getenv("todotxt_filepath"))
		.split("\n")
		.map((item) => {
			lineNo++;
			const urls = item.match(urlRegex);
			const urlOpenSubtitle = urls ? "⌘: Open " + urls.join(" ") : "🚫 No URL in the todo.";
			const completed = item.startsWith("x") ? "completed" : "";

			return {
				title: item,
				subtitle: completed,
				arg: lineNo,
				mods: {
					cmd: {
						arg: urls,
						valid: Boolean(urls),
						subtitle: urlOpenSubtitle,
					},
				}
			};
		});

	return JSON.stringify({ items: todos });
}
