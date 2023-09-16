//──────────────────────────────────────────────────────────────────────────────

// CONFIG: default markdown app, if markdown file is not located in a Vault
const markdownApp = "Neovide Helper";

//──────────────────────────────────────────────────────────────────────────────

// DOCS: https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html
/** @typedef {Object} PathObject
 * @property {{(): string}} toString
 */

/** based on https://forum.obsidian.md/t/make-obsidian-a-default-app-for-markdown-files-on-macos/22260
 * @param {PathObject[]} argv input for automator is an array of macOS path objects.
 */
// biome-ignore lint/correctness/noUnusedVariables: run
function run(argv) {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	// GUARD: OPENED WITHOUT FILE
	if (argv.length === 0) {
		app.displayNotification("Set it as the default app for markdown files", {
			withTitle: "The Obsidian Opener cannot start by itself.",
		});
		return;
	}

	// turn pathobjects into strings
	const pathArray = argv.map((pathObj) => pathObj.toString());

	// GET VAULTS
	const obsidianJsonFilePath =
		app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	const vaults = JSON.parse(app.read(obsidianJsonFilePath)).vaults;

	// CONDITIONS FOR DECIDING WHERE TO OPEN
	const firstFile = pathArray[0];
	const isFileInObsidianVault = Object.values(vaults).some((vault) => firstFile.startsWith(vault.path));
	const obsidianIsFrontmost = Application("Obsidian").frontmost();
	const isInHiddenFolder = firstFile.includes("/.");

	// Hidden Folder means '.obsidian' or '.trash', which cannot be opened in Obsidian
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
