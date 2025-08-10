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

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const convoFile = $.NSProcessInfo.processInfo.environment.objectForKey("chatgpt_conv_json").js;
	if (!convoFile) {
		const errmsg = "conversation.json file not defined in workflow settings";
		return JSON.stringify({ items: [{ title: errmsg, valid: false }] });
	}
	if (!fileExists(convoFile)) {
		return JSON.stringify({
			items: [{ title: "Error: File does not exist.", subtitle: convoFile, valid: false }],
		});
	}
	const conversations = JSON.parse(readFile(convoFile));

	/** @type {AlfredItem[]} */
	// @ts-expect-error -> quicker
	const alfredItems = conversations.map((conv) => {
		const messageCount = Object.keys(conv.mapping).length;

		const date = new Date(conv.create_time * 1000); // openai saves stamps in seconds

		/** @type {Intl.DateTimeFormatOptions} */
		const dateFmt = { day: "numeric", month: "short", year: "numeric" };
		const dateStr = date.toLocaleString("en-US", dateFmt);

		const subtitle= [
			dateStr,
			conv.is_archived ? "🗄️" : "",
			messageCount + " 💬",
		].filter(Boolean).join("    ");
		
		return {
			title: conv.title,
			subtitle: subtitle,
			arg: "https://chatgpt.com/c/" + conv.id,
		};
	});

	return JSON.stringify({ items: alfredItems });
}
