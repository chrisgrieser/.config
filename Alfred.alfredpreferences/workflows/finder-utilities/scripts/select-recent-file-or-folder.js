#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function camelCaseMatch(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type {string[]} */
	const recentFiles = Application("System Events")
		.processes.byName("Finder")
		.menuBars[0].menuBarItems.byName("Apple")
		.menus[0].menuItems.byName("Recent Items")
		.menus[0].menuItems.name();
	const recentFilesStart = recentFiles.indexOf("Documents") + 1;
	const recentFilesEnd = recentFiles.indexOf("Servers") - 1;

	let menuId = recentFilesStart;
	const recentItemsMap = recentFiles
		.slice(recentFilesStart, recentFilesEnd)
		.filter((item) => !item.includes("“")) // remove the "Show item…" entries
		.map((item) => {
			// HACK workaround with id necessary, since only file names, but not file paths are
			// saved in the menu, so that the IDs need to be used to emulate a click in
			// the next applescript step
			const itemData = {
				name: item,
				menuId: menuId,
				type: "file",
			};
			menuId = menuId + 2; // every other id results in showing the item
			return itemData;
		});

	//───────────────────────────────────────────────────────────────────────────

	menuId = 0;
	const recentFolders = Application("System Events")
		.processes.byName("Finder")
		.menuBars[0].menuBarItems.byName("Go")
		.menus[0].menuItems.byName("Recent Folders")
		.menus[0].menuItems.name()
		.slice(0, -2)
		.map((/** @type {string} */ item) => {
			const itemData = { name: item, menuId: menuId, type: "folder" };
			menuId++;
			return itemData;
		});

	/** @type {AlfredItem[]} */
	const recentAll = [...recentFolders, ...recentItemsMap].map((item) => {
		const revealSubtitle = item.type === "file" ? "⌥: Reveal in Finder" : "❌ Not for folder";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: item.name,
			uid: item.name,
			match: camelCaseMatch(item.name),
			icon: { path: item.type + ".png" },
			arg: item.menuId.toString(),
			mods: {
				alt: {
					arg: item.menuId + 1,
					valid: item.type === "file",
					subtitle: revealSubtitle,
				},
			},
			variables: { type: item.type },
		};
		return alfredItem;
	});

	return JSON.stringify({ items: recentAll });
}
