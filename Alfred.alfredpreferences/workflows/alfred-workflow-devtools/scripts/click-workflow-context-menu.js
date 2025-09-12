#!/usr/bin/env osascript -l JavaScript
// biome-ignore-all lint/complexity/useLiteralKeys: clearer this way here
// SOURCE https://www.alfredforum.com/topic/23327-edit-workflow-details-%E2%80%94-open-workflow-detail-window-with-a-hotkey/#comment-122193
//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const menuItemName = argv[0];
	const [major, minor, _] = $.getenv("alfred_version").split(".");
	const is5dot7 = Number.parseInt(major, 10) >= 5 && Number.parseInt(minor, 10) >= 7;

	if (is5dot7 && menuItemName === "Edit Details") {
		// https://www.alfredforum.com/topic/23327-edit-workflow-details-%E2%80%94-open-workflow-detail-window-with-a-hotkey/#comment-122526
		const bundleId = $.getenv("alfred_workflow_bundleid");
		Application("com.runningwithcrayons.Alfred").revealWorkflow(bundleId, { details: true });
	} else {
		const alfredPrefsWin = Application("System Events").processes["Alfred Preferences"];
		const scrollArea = alfredPrefsWin.splitterGroups[0].scrollAreas[0];

		// Show the context menu
		scrollArea.tables[0].actions["AXShowMenu"].perform();

		delay(0.3);

		// Click menu item with specified name
		scrollArea.tables[0].menus[0].menuItems[menuItemName].actions["AXPress"].perform();
	}
}
