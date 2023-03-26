#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const sidenotes = Application("Sidenotes");
const reminders = Application("Reminders");

const today = new Date();
const folder = sidenotes.folders.byName("Base");

//──────────────────────────────────────────────────────────────────────────────

// https://leancrew.com/all-this/2017/08/my-jxa-problem/
// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
const todaysTasks = reminders.defaultList().reminders.whose({ dueDate: { _lessThan: today } });

// - needs iterating for loop since JXA Record Array cannot be looped with `foreach` or `for in`
// - backwards, to not change the indices at loop runtime
for (let i = todaysTasks.length - 1; i >= 0; i--) {
	const task = todaysTasks[i];

	let newNoteContent = task.name();
	if (task.body()) newNoteContent += "\n" + task.body();

	sidenotes.createNote({
		folder: folder,
		text: newNoteContent,
		ispath: false,
	});

	task.delete();
}

//──────────────────────────────────────────────────────────────────────────────

reminders.includeStandardAdditions = true;
reminders.quit();
