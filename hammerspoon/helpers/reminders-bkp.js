#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine backup dir
	const dataDir = app.doShellScript('source "$HOME/.zshenv" && echo "$DATA_DIR"').trim();
	const isoDate = new Date().toISOString().split("T")[0];
	const backupLocation = `${dataDir}/Backups/Reminders/${isoDate}.json`;

	const remApp = Application("Reminders");
	const reminders = remApp.defaultList().reminders();
	const json = [];
	for (let i = 0; i < reminders.length; i++) {
		const reminder = reminders[i];
		const name = reminder.name();
		json.push({
			name: name,
			completionDate: reminder.completionDate(),
			dueDate: reminder.dueDate(),
		});
	}

	remApp.quit();
	writeToFile(backupLocation, JSON.stringify(json));
}
