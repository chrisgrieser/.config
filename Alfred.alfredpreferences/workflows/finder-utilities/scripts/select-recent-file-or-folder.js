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
	const recentFiles = Application("System Events")
		.processes.byName("Finder")
		.menuBars[0].menuBarItems.byName("Apple")
		.menus[0].menuItems.byName("Recent Items")
		.menus[0].menuItems.name();
	const recentFilesStart = recentFiles.indexOf("Documents") + 1;
	const recentFilesEnd = recentFiles.indexOf("Servers") - 1;

	let menuId = -1;
	const recentItemsMap = recentFiles
		.slice(recentFilesStart, recentFilesEnd)
		.filter((/** @type {string} */ item) => !item.includes("“"))
		.map((/** @type {string} */ item) => {
			// HACK workaround with id necessary, since only file names, but not file paths are
			// saved in the menu, so that the IDs need to be used to emulate a click in
			// the next applescript step
			menuId = menuId + 2;
			return {
				name: item,
				menuId: recentFilesStart + menuId,
				type: "file",
			};
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
			menuId++;
			return { name: item, menuId: menuId, type: "dir" };
		});

	/** @type {AlfredItem[]} */
	const recentAll = [...recentItemsMap, ...recentFolders].map((item) => {
		let iconPath = "../../../_custom-filetype-icons/";
		iconPath += item.type === "file" ? "blank.png" : "folder.png";
		const subtitle = item.type === "file" ? "⌥: Reveal in Finder" : "❌ Not for folder";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: item.name,
			uid: item.name,
			match: camelCaseMatch(item.name),
			icon: { path: iconPath },
			arg: item.menuId.toString(),
			mods: {
				alt: {
					arg: item.menuId + 1,
					valid: item.type === "file",
					subtitle: subtitle,
				},
			},
			variables: { type: item.type },
		};
		return alfredItem;
	});

	return JSON.stringify({ items: recentAll });
}
