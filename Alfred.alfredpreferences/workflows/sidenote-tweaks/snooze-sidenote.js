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
const trash


const content = sidenotes.currentNote().text();
const title = sidenotes.currentNote().title();
Application("SideNotes").currentNote().title();
sidenotes.currentNote().delete();
writeToFile(app.pathTo("home folder").)


// create reminder
reminders.defaultList().make({ new: "reminder", withProperties: { name: content } });
// alternative method
// const newReminder = reminders.Reminder({ name: "Title for reminder", body: "Notes for the reminder" });
// reminders.lists.byName("List Name").reminders.push(newReminder);


// direct return for notification
content; 
