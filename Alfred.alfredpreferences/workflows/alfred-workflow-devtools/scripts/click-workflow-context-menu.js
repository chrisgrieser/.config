#!/usr/bin/env osascript -l JavaScript
// biome-ignore-all lint/complexity/useLiteralKeys: clearer this way here
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const menuItemName = argv[0];

	const alfredPrefsWin = Application("System Events").processes["Alfred Preferences"];
	const scrollArea = alfredPrefsWin.splitterGroups[0].scrollAreas[0];

	// Show the context menu
	scrollArea.tables[0].actions["AXShowMenu"].perform();

	delay(0.3);

	// Click menu item with specified name
	scrollArea.tables[0].menus[0].menuItems[menuItemName].actions["AXPress"].perform();
}
