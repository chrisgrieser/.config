#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}


/** @param {string} str */
function unicodeStrikethough(str) {
	// https://stackoverflow.com/questions/38926669/strike-through-plain-text-with-unicode-characters
	return str
		.split("")
		.map((char) => char + "\u0336")
		.join("");
}
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let lineNo = 0;
	const urlRegex =
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g;

	/** @type AlfredItem[] */
	const todos = readFile($.getenv("todotxt_filepath"))
		.split("\n")
		.map((item) => {
			lineNo++;
			const urls = item.match(urlRegex);
			let urlOpenSubtitle = urls ? "⌘: Open URL" : "🚫 No URL in the todo.";
			const completed = item.startsWith("x") ? "completed" : "";
			if (!completed) urlOpenSubtitle += " & mark as completed"
			const displayText = completed ? unicodeStrikethough(item) : item;

			return {
				title: displayText,
				arg: lineNo,
				mods: {
					cmd: {
						valid: Boolean(urls),
						subtitle: urlOpenSubtitle,
					},
				},
				// for editing
				variables: { text: item, lineNo: lineNo },
			};
		});

	return JSON.stringify({ items: todos });
}
