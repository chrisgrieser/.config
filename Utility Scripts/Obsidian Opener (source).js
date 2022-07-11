#!/usr/bin/env osascript -l JavaScript
function run(input) {

	// 👉 Config: Enter your Default non-Obsidian Markdown App here
	const markdownApp = "Sublime Text";

	// -----------------------
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const pathArray = input.toString().split(",");

	const obsidianJsonFilePath = app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	const vaults = JSON.parse(app.read(obsidianJsonFilePath)).vaults;

	// Deciding conditions
	const isFileInObsidianVault = Object.values(vaults).some(v => pathArray[0].startsWith(v.path));
	const obsidianIsFrontmost = Application("Obsidian").frontmost();
	const isInHiddenFolder = pathArray[0].includes("/.");

	// Hidden Folder means '.obsidian' or '.trash', which cannot be opened in Obsidian
	// When Obsidian is frontmost, the "Open with default app" core plugin is used
	const openInObsidian = isFileInObsidianVault && !isInHiddenFolder && !obsidianIsFrontmost;

	if (openInObsidian) {
		app.openLocation("obsidian://open?path=" + encodeURIComponent(pathArray[0]));
		if (pathArray.length > 1) {
			app.displayNotification("opening: " + pathArray[0], {
				withTitle: "Obsidian can only open one file at a time.",
				soundName: "Basso"
			});
		}
	} else {
		// opens *all* selected files
		const quotedPathArray = "'" + pathArray.join("' '") + "'";
		app.doShellScript("open -a '" + markdownApp + "' " + quotedPathArray);
	}
}
