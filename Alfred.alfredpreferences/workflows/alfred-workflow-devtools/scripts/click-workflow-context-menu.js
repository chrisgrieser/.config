#!/usr/bin/env osascript -l JavaScript
// SOURCE https://www.alfredforum.com/topic/23327-edit-workflow-details-%E2%80%94-open-workflow-detail-window-with-a-hotkey/#comment-122193
//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const menuItemName = argv[0];
	const [major, minor, _] = $.getenv("alfred_version").split(".");
	const is5dot7 = Number.parseInt(major, 10) >= 5 && Number.parseInt(minor, 10) >= 7;

	if (is5dot7 && menuItemName === "Edit Details") {
		// https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
		const historyFile =
			app.pathTo("home folder") + "/Library/Application Support/Alfred/history.json";
		const navHistory = JSON.parse(readFile(historyFile)).preferences.workflows;
		const currentWorkflowUid = navHistory[0];

		// https://www.alfredforum.com/topic/23327-edit-workflow-details-%E2%80%94-open-workflow-detail-window-with-a-hotkey/#comment-122526
		Application("com.runningwithcrayons.Alfred").revealWorkflow(currentWorkflowUid, {
			details: true,
		});
	} else if (menuItemName === "Enabled") {
		const alfredPrefsWin = Application("System Events").processes["Alfred Preferences"];
		const scrollArea = alfredPrefsWin.splitterGroups[0].scrollAreas[0];

		// Show the context menu
		// biome-ignore lint/complexity/useLiteralKeys: clearer this way here
		scrollArea.tables[0].actions["AXShowMenu"].perform();

		delay(0.3);

		// Click menu item with specified name
		// biome-ignore lint/complexity/useLiteralKeys: clearer this way here
		scrollArea.tables[0].menus[0].menuItems[menuItemName].actions["AXPress"].perform();
	} else {
		throw new Error(`Unknown menu item: ${menuItemName}`);
	}
}
