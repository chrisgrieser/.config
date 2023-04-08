#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function writeToFile(file, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

const sidenotes = Application("Sidenotes");
const content = sidenotes.currentNote().content();
const title = sidenotes.currentNote().title();

// Trash Note, but keep copy in trash folder
const maxNameLen = 50;
let safeTitle = sidenotes
	.currentNote()
	.title()
	.replace(/[/\\:;,"'#()[\]=<>{}|]/gm, "");
if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
writeToFile(trashNotePath, content);
sidenotes.currentNote().delete();

//──────────────────────────────────────────────────────────────────────────────
// CREATE REMINDER

const reminders = Application("Reminders");
const tomorrow = new Date();
tomorrow.setDate(tomorrow.getDate() + 1);

reminders.defaultList().make({
	new: "reminder",
	withProperties: {
		name: title,
		alldayDueDate: tomorrow,
		body: content,
	},
});
// alternative method
// const newReminder = reminders.Reminder({ name: "Title for reminder", body: "Notes for the reminder" });
// reminders.lists.byName("List Name").reminders.push(newReminder);

reminders.activate(); // TODO quit, when date selection is implemented





const msg = "💤 Snoozed to tomorrow;;" + content;
msg; // direct return for notification
