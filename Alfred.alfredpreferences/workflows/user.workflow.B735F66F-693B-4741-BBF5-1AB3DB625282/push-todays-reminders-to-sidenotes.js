#!/usr/bin/env osascript -l JavaScript
// https://leancrew.com/all-this/2017/08/my-jxa-problem/
// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
//──────────────────────────────────────────────────────────────────────────────

ObjC.import("stdlib");
const sidenotes = Application("Sidenotes");
const remin = Application("Reminders");

const today = new Date();
const folder = sidenotes.folders.byName($.getenv("new_note_folder"));

//──────────────────────────────────────────────────────────────────────────────

const todaysTasks = remin.defaultList().reminders.whose({ dueDate: { _lessThan: today } });
console.log("todaysTasks:", todaysTasks.length);

todaysTasks.forEach(task => {
	let newNoteContent = task.name();
	if (task.body()) newNoteContent += "\n" + task.body();
	sidenotes.createNote({
		folder: folder,
		text: newNoteContent,
		ispath: false,
	});
});

//──────────────────────────────────────────────────────────────────────────────

// todaysTasks.delete();
