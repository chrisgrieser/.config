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

/** @param {number} date @return {string} relative date */
function relativeDate(date) {
	const deltaHours = (Date.now() - date) / 1000 / 60 / 60;
	let /** @type {"year"|"month"|"week"|"day"|"hour"} */ unit;
	let delta;
	if (deltaHours < 24) {
		unit = "hour";
		delta = Math.floor(deltaHours);
	} else if (deltaHours < 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaHours / 24);
	} else if (deltaHours < 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaHours / 24 / 7);
	} else if (deltaHours < 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaHours / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaHours / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "narrow", numeric: "auto" });
	return formatter.format(-delta, unit);
}

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
		const messages = []
		for (const [_, item] of Object.entries(conv.mapping)) {
			const isText = item.message?.content?.content_type === "text";
			if (!isText) continue;
			const content = item.message?.content?.parts?.join("\n");
			if (isText && content) continue;
			messages.push(item.message.content.parts.join("\n"));
		}

		const dateStr = relativeDate(conv.update_time * 1000); // openai saves stamps in seconds

		const subtitle= [
			dateStr,
			conv.is_archived ? "🗄️" : "",
			messages.length + " 💬",
		].filter(Boolean).join("    ");
		
		return {
			title: conv.title,
			subtitle: subtitle,
			arg: "https://chatgpt.com/c/" + conv.id,
		};
	});

	return JSON.stringify({ items: alfredItems });
}
