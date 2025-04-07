#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────


/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrowser = frontBrowser() !== "no browser";
	const keywordUsed = Boolean(argv[0]);
	let remTitle = "";
	let remBody = "";
	const remList = $.getenv("reminder_list");

	if (keywordUsed) {
		remTitle = (argv[0] || "")
			.replaceAll("'", "\\'") // escape single quotes, since only character `$''` does not escape
			.trim();
	} else {
		// get selected text
		app.setTheClipboardTo(""); // empty clipboard in case of no selection
		Application("System Events").keystroke("c", { using: ["command down"] });
		delay(0.1);
		remTitle = app.theClipboard().toString();
	}

	// GUARD
	if (!remTitle && !isBrowser) return "";

	// add rem for today
	if (isBrowser && !keywordUsed) {
		const { url, title } = browserTab();
		remBody = url;
		remTitle = title;
	}

	const args = ["reminders", "add", `"${remList}"`, "--due-date=today"];
	if (remBody) args.push(`--notes="${remBody}"`); // empty string in `--notes` causes error
	args.push(remBody);
	args.push("--", `$'${remTitle}'`); // $'' to escape special chars
	app.doShellScript(args.join(" "));

	// Pass for Alfred notification
	return remTitle;
}
