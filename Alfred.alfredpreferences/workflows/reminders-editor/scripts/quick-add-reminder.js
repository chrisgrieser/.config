#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

function getFrontAppName() {
	return Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
}

function frontBrowser() {
	const frontAppName = getFrontAppName();
	// biome-ignore format: -
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
	const webkitVariants = ["Safari", "Webkit"];
	const isChromium = chromiumVariants.some((appName) => frontAppName.startsWith(appName));
	const isWebKit = webkitVariants.some((appName) => frontAppName.startsWith(appName));

	if (isChromium) return "chromium";
	if (isWebKit) return "webkit";
	return "no browser";
}

function browserTab() {
	const frontmostApp = Application(getFrontAppName());
	const browserType = frontBrowser();

	let title;
	let url;
	if (browserType === "chromium") {
		// @ts-ignore
		url = frontmostApp.windows[0].activeTab.url();
		// @ts-ignore
		title = frontmostApp.windows[0].activeTab.name();
	} else if (browserType === "webkit") {
		// @ts-ignore
		url = frontmostApp.documents[0].url();
		// @ts-ignore
		title = frontmostApp.documents[0].name();
	} else {
		return { url: "", title: "" };
	}
	return { url: url, title: title };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrowser = frontBrowser() !== "no browser";

	const keywordUsed = Boolean(argv[0]);
	let input = "";
	if (keywordUsed) {
		input = argv[0] || "";
	} else {
		// get selected text
		app.setTheClipboardTo(""); // empty clipboard in case of no selection
		Application("System Events").keystroke("c", { using: ["command down"] });
		delay(0.1);
		input = app.theClipboard().toString();
	}

	// GUARD
	if (!input && !isBrowser) return "";

	// url + selection if from browser
	const { url, title } = browserTab();
	const body = isBrowser && !keywordUsed ? url : "";
	if (!input && isBrowser) input = title;

	// ADD REMINDER FOR TODAY
	const rem = Application("Reminders");
	const list = $.getenv("reminder_list");

	// PENDING https://github.com/keith/reminders-cli/issues/79
	// using reminders CLI does not allow for alldayDueDate, therefore using JXA version
	// const notes = isBrowser && !keywordUsed ? `--notes=${browserTab().title}` : "";
	// app.doShellScript(`reminders add "${list}" "${input}" --due-date="today" ${notes}`);

	const today = new Date();
	const newReminder = rem.Reminder({
		name: input.trim(),
		body: body,
		alldayDueDate: today,
	});
	rem.lists.byName(list).reminders.push(newReminder);
	rem.quit();

	// Pass for Alfred notification
	return input;
}