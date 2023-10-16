#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: run
function run() {
	// CONFIG
	const dotToUse = 1;

	const reminders = Application("Reminders");
	const tots = Application("Tot");
	tots.includeStandardAdditions = true;

	const today = new Date();

	// https://leancrew.com/all-this/2017/08/my-jxa-problem/
	// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
	const todaysTasks = reminders.defaultList().reminders.whose({ dueDate: { _lessThan: today } });

	if (!todaysTasks || todaysTasks.length === 0) {
		if (reminders) reminders.quit();
		return;
	}

	let addedTasks = 0;
	let acc = ""
	// - needs iterating for loop since JXA Record Array cannot be looped with `foreach` or `for in`
	// - backwards, to not change the indices at loop runtime
	for (let i = todaysTasks.length - 1; i >= 0; i--) {
		const task = todaysTasks[i];
		if (!task?.name()) continue;

		const body = task.body();
		const title = task.name();
		const content = body ? `\n## ${title}\n${body}` : "– " + title;

		acc += "\n" + content;
		addedTasks++;

		task.delete(); // DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
	}
	tots.openLocation(`tots://${dotToUse}/append?text=${encodeURIComponent(acc)}`);

	delay(0.1);
	if (reminders) reminders.quit(); // FIX Reminder.app being left open

	// information hwo many tasks were added for hammrspoon
	if (addedTasks > 0) return addedTasks;
}
