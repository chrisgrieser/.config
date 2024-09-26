#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const dockSwitcherDir = $.getenv("dock_layout_storage");
	const stdout = app.doShellScript(`ls -1 "${dockSwitcherDir}/"*.plist`).trim();

	// GUARD 
	if (stdout === "") {
		const item = { title: "No layouts found.", subtitle: 'Create a layout via ":dock_newlayout"' };
		return JSON.stringify({ items: [item] });
	}

	/** @type {AlfredItem[]} */
	const layoutArr = stdout.split("\r").map((layout) => {
		const name = layout.replace(/.*\/(.*)\.plist/, "$1");
		return {
			title: name,
			subtitle: "⏎: Load",
			match: alfredMatcher(name),
			arg: name,
			uid: name,
			mods: {
				cmd: { subtitle: `⌘: Save current dock as "${name}"` },
			},
		};
	});

	return JSON.stringify({ items: layoutArr });
}
