#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

const toFolder = "Base"

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: run
function run() {
	const sidenotes = Application("SideNotes");
	const reminders = Application("Reminders");

	const today = new Date();
	const folder = sidenotes.folders.byName(toFolder);
	const delaySecs = 0.05;

	// https://leancrew.com/all-this/2017/08/my-jxa-problem/
	// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
	const todaysTasks = reminders.defaultList().reminders.whose({ dueDate: { _lessThan: today } });

	if (!todaysTasks || todaysTasks.length === 0) {
		if (reminders) reminders.quit();
		return;
	}

	// - needs iterating for loop since JXA Record Array cannot be looped with `foreach` or `for in`
	// - backwards, to not change the indices at loop runtime
	for (let i = todaysTasks.length - 1; i >= 0; i--) {
		const task = todaysTasks[i];
		if (!task || !task.name()) continue;

		const body = task.body();
		const title = task.name();
		const newNoteContent = body ? `# ${title}\n${body}` : title;

		sidenotes.createNote({
			folder: folder,
			text: newNoteContent,
			ispath: false,
		});
		task.delete();
	}

	delay(delaySecs);
	if (reminders) reminders.quit();

	// close sidenotes again
	delay(delaySecs);
	Application("System Events").keystroke("w", { using: ["command down"] });
}
