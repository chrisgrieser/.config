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

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// determine day
	const inDays = 1; // CONFIG
	const dueDate = new Date();
	dueDate.setDate(dueDate.getDate() + inDays);

	// get text
	const hotkeyUsed = Boolean(!argv[0]);
	let todo;
	if (hotkeyUsed) {
		const se = Application("System Events");
		se.includeStandardAdditions = true;
		se.keystroke("c", { using: ["command down"] });
		delay(0.1); // wait for clipboard
		todo = app.theClipboard();

		// delete task // TODO use todotxt syntax
		se.keyCode(51); // delete
		delay(0.05);
		se.keyCode(76); // confirm
	} else {
		const lineNo = parseInt(argv[0]);
		const allTodos = readFile($.getenv("todotxt_filepath")).split("\n");
		todo = allTodos.splice(lineNo - 1, 1)[0];
		writeToFile($.getenv("todotxt_filepath"), allTodos.join("\n"));
	}

	// add reminder
	const rem = Application("Reminders");
	const newReminder = rem.Reminder({
		name: todo,
		alldayDueDate: dueDate,
	});
	rem.defaultList().reminders.push(newReminder);
	rem.quit();

	// return for Alfred notification
	return todo;
}
