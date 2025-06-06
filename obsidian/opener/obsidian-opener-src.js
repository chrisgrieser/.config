// SOURCE https://forum.obsidian.md/t/make-obsidian-a-default-app-for-markdown-files-on-macos/22260
//──────────────────────────────────────────────────────────────────────────────

// CONFIG default markdown app, if markdown file is not located in a Vault
const markdownApp = "Neovide";

//──────────────────────────────────────────────────────────────────────────────

/** @param {PathObj[]} argv input for automator is an array of macOS path objects. */
function run(argv) {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const pathArray = argv.map((pathObj) => pathObj.toString());

	// GUARD opened without file
	if (argv.length === 0) {
		app.displayNotification("Set it as the default app for markdown files", {
			withTitle: "The Obsidian Opener cannot start by itself.",
		});
		return;
	}

	// GET VAULTS
	const obsidianJsonFilePath =
		app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	const vaults = JSON.parse(app.read(obsidianJsonFilePath)).vaults;

	// CONDITIONS FOR DECIDING WHERE TO OPEN
	const firstFile = pathArray[0];
	const isFileInObsidianVault = Object.values(vaults).some((vault) =>
		firstFile.startsWith(vault.path),
	);
	const obsidianIsFrontmost = Application("Obsidian").frontmost();
	const isInHiddenFolder = firstFile.includes("/.");

	// Hidden folder means '.obsidian' or '.trash', which cannot be opened in Obsidian
	// When Obsidian is frontmost, it means the "Open in default app" command was
	// used, for which we also do not open right in Obsidian again
	const openInObsidian = isFileInObsidianVault && !isInHiddenFolder && !obsidianIsFrontmost;

	// OPENING
	if (openInObsidian) {
		app.openLocation("obsidian://open?path=" + encodeURIComponent(firstFile));
		if (pathArray.length > 1) {
			app.displayNotification("opening: " + firstFile, {
				withTitle: "Obsidian can only open one file at a time.",
			});
		}
	} else {
		// opens *all* selected files if they are not in Obsidian
		const quotedPathArray = `'${pathArray.join("' '")}'`;
		app.doShellScript(`open -a '${markdownApp}' ${quotedPathArray}`);
	}
}
