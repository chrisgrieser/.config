#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const recentItems = app
		.doShellScript(
			`osascript -e 'tell application "System Events" to tell (process 1 where frontmost is true) to set allItems to every menu item of menu of menu item "Recent Items" of menu 1 of menu bar 1'`,
		)
		.split(", ")
		.map((item) => item.slice(10).split(" of ")[0]);

	const start = recentItems.indexOf("Documents") + 1;
	console.log("start: " + start);
	const end = recentItems.indexOf("Servers") - 1;

	let id = 0;
	const recentFolders = app
		.doShellScript(
			`osascript -e 'tell application "System Events" to tell (process "Finder") to set allItems to every menu item of menu of menu item "Recent Folders" of menu "Go" of menu bar 1'`,
		)
		.split(", ")
		.slice(0, -2)
		.map((item) => item.slice(10).split(" of ")[0])
		.map((item) => {
			id++;
			return { name: item, id: id, type: "dir" };
		});

	id = 0;
	const recentItemsMap = recentItems
		.map((item) => {
			// INFO workaround with id necessary, since only file names, but not file paths are
			// saved in the menu, so that the IDs need to be used to emulate a click in
			// the next applescript step
			id++;
			return { name: item, id: id, type: "file" };
		})
		.slice(start, end)
		.filter((item) => !item.name.includes("“"));

	/** @type {AlfredItem[]} */
	const recentAll = [...recentFolders, ...recentItemsMap].map((item) => {
		const revealID = item.type === "file" ? item.id : item.id + 1;
		let iconPath = "../../../_custom-filetype-icons/";
		iconPath += item.type === "file" ? "blank.png" : "folder.png";
		const subtitle = item.type === "file" ? "⌥: Reveal in Finder" : "❌ not available for folder";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: item.name,
			uid: item.name,
			match: alfredMatcher(item.name),
			mods: {
				alt: {
					arg: revealID.toString(),
					valid: item.type === "f",
					subtitle: subtitle,
				},
			},
			icon: { path: iconPath },
			arg: item.id.toString(),
			variables: { type: item.type },
		};
		return alfredItem;
	});

	return JSON.stringify({ items: recentAll });
}
