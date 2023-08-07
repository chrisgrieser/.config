#!/usr/bin/env osascript -l JavaScript
//──────────────────────────────────────────────────────────────────────────────
//──────────────────────────────────────────────────────────────────────────────

// ⚙️ CONFIG

// default markdown app, if markdown file is not located in a Vault
const markdownApp = "Neovim";

// where outside canvas symlinks will be placed
const vaultDummyFolder = "~/main-vault/Meta/outside-canvas-symlink-temp/";

//──────────────────────────────────────────────────────────────────────────────
//───────────────────────────────────────────────────────────────────────────

// DOCS: https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html
/** @typedef {Object} PathObject
* @property {{(): string}} toString
*/

/** based on https://forum.obsidian.md/t/make-obsidian-a-default-app-for-markdown-files-on-macos/22260
 * @param {PathObject[]} argv input for automator is an array of macOS path objects. 
 */
// rome-ignore lint/correctness/noUnusedVariables: run
function run(argv) {
	// turn pathobjects into strings
	const pathArray = argv.map((pathObj) => pathObj.toString());

	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const vaultDummy = vaultDummyFolder.replace(/^~/, app.pathTo("home folder"));
	const obsidianJsonFilePath =
		app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	const vaults = JSON.parse(app.read(obsidianJsonFilePath)).vaults;

	app.displayNotification(JSON.stringify(pathArray), { withTitle: "stringified" });
	app.setTheClipboardTo(JSON.stringify(pathArray));

	// conditions for deciding where to open
	let firstFile = pathArray[0];
	const isFileInObsidianVault = Object.values(vaults).some((vault) => firstFile.startsWith(vault.path));
	const obsidianIsFrontmost = Application("Obsidian").frontmost();
	const isInHiddenFolder = firstFile.includes("/.");

	// Hidden Folder means '.obsidian' or '.trash', which cannot be opened in Obsidian
	// When Obsidian is frontmost, it means the "Open in default app" command was
	// used, for which we also do not open right in Obsidian again
	const openInObsidian = isFileInObsidianVault && !isInHiddenFolder && !obsidianIsFrontmost;
	const canvasOutside = firstFile.endsWith(".canvas") && (!isFileInObsidianVault || isInHiddenFolder);

	// symlink outside canvas
	if (canvasOutside) {
		const firstFileBasename = firstFile.replace(/.*\//, "");
		app.doShellScript(`mkdir -p "${vaultDummy}"`);
		app.doShellScript(`rm "${vaultDummy}/"* || true`); // remove any existing symlinks
		app.doShellScript(`ln -sf '${firstFile}' '${vaultDummy}'`);
		delay(0.1); // ensure the new symlink is indexed by Obsidian
		firstFile = vaultDummy + firstFileBasename;
	}

	// Opening
	if (openInObsidian || canvasOutside) {
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
