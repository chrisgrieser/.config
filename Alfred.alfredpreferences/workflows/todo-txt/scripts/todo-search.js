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
		.map((text) => {
			lineNo++;
			const urls = text.match(urlRegex);
			const isCompleted = text.startsWith("x") ? "completed" : "";
			const displayText = isCompleted ? unicodeStrikethough(text) : text;

			let urlOpenSubtitle = urls ? "⌘: Open URL" : "🚫 No URL in the todo.";
			let copySubtitle = "⌥: Copy to clipboard";
			if (!isCompleted) {
				urlOpenSubtitle += " & mark as completed"
				copySubtitle += " & mark as completed"
			}

			return {
				title: displayText,
				variables: { text: text, lineNo: lineNo },
				text: { copy: text, largetype: text },
				mods: {
					cmd: {
						arg: "open-url",
						valid: Boolean(urls),
						subtitle: urlOpenSubtitle,
					},
					alt: {
						arg: "copy",
						subtitle: copySubtitle,
					},
					ctrl: {
						arg: "toggle-completed",
						subtitle: isCompleted ? "⌃: Unmark as completed" : "⌃: Mark as completed",
					},
				},
			};
		});

	return JSON.stringify({ items: todos });
}
