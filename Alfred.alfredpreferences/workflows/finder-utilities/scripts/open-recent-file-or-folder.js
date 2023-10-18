#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib")

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const menuId = parseInt(argv[0]);
	const type = $.getenv("type");

	const menu = type === "file" ? "Apple" : "Go";
	const submenu = type === "file" ? "Recent Items" : "Recent Folders";

	Application("Finder").activate();
	Application("System Events")
		.processes.byName("Finder")
		.menuBars[0].menuBarItems.byName(menu)
		.menus[0].menuItems.byName(submenu)
		.menus[0].menuItems[menuId].click();
}
