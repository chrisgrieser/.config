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
const reminders = Application("Reminders");
const content = sidenotes.currentNote().text();

// Trash Note, but keep copy in trash folder
const maxNameLen = 50;
let safeTitle = sidenotes
	.currentNote()
	.title()
	.replace(/[/\\:;,"'#()[\]=<>{}]/gm, "");
if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
writeToFile(trashNotePath, content);
sidenotes.currentNote().delete();

// create reminder
reminders.defaultList().make({ new: "reminder", withProperties: { name: content } });
// alternative method
// const newReminder = reminders.Reminder({ name: "Title for reminder", body: "Notes for the reminder" });
// reminders.lists.byName("List Name").reminders.push(newReminder);

// direct return for notification
content;
