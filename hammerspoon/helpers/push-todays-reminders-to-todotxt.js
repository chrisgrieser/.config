#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}
//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// biome-ignore lint/correctness/noUnusedVariables: run
function run(argv) {
	const reminders = Application("Reminders");
	const today = new Date();
	const todotxt = argv[0];

	// https://leancrew.com/all-this/2017/08/my-jxa-problem/
	// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
	const todaysTasks = reminders.defaultList().reminders.whose({ dueDate: { _lessThan: today } });

	if (!todaysTasks || todaysTasks.length === 0) {
		if (reminders) reminders.quit();
		return;
	}

	let addedTasks = 0;
	let accText = "";
	// - needs iterating for loop since JXA Record Array cannot be looped with `foreach` or `for in`
	// - backwards, to not change the indices at loop runtime
	for (let i = todaysTasks.length - 1; i >= 0; i--) {
		const task = todaysTasks[i];
		if (!task?.name()) continue;

		const body = task.body();
		const title = task.name();
		const content = body ? `\n## ${title}\n${body}` : title;

		accText += "\n" + content;
		addedTasks++;

		task.delete(); // DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
	}

	// add to todotxt
	writeToFile(todotxt, readFile(todotxt) + accText);

	// finish
	delay(0.3);
	if (reminders) reminders.quit(); // FIX Reminder.app being left open
	if (addedTasks > 0) return addedTasks; // information how many tasks were added for hammerspoon,
}
