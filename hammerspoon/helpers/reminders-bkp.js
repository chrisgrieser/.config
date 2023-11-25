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
	const dataDir = app.doShellScript('source "$HOME/.zshenv" && echo "$DATA_DIR"').trim();
	const isoToday = new Date().toISOString().split("T")[0];
	const backupLocation = `${dataDir}/Backups/Reminders/${isoToday}.json`;
	const fourDaysAgo = new Date(Date.now() - 4 * (24 * 60 * 60 * 1000));

	const remApp = Application("Reminders");
	const reminders = remApp.defaultList().reminders();
	const json = [];

	for (let i = 0; i < reminders.length; i++) {
		const reminder = reminders[i];
		const completionDate = reminder.completionDate();

		// delete old reminders
		if (completionDate > fourDaysAgo) {
			reminder.delete();
			continue;
		}

		// backup recent reminders
		json.push({
			name: reminder.name(),
			completionDate: completionDate,
			dueDate: reminder.dueDate(),
		});
	}

	writeToFile(backupLocation, JSON.stringify(json));
	remApp.quit();
}
