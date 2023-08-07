#!/usr/bin/env osascript -l JavaScript
// INFO https://forum.obsidian.md/t/make-obsidian-a-default-app-for-markdown-files-on-macos/22260

//──────────────────────────────────────────────────────────────────────────────

// 👉 CONFIG
const markdownApp = "Neovim"; // default markdown app
const vaultDummyFolder = "~/main-vault/Meta/outside-canvas-symlink-temp/"; // where outside canvas symlinks will be placed

//───────────────────────────────────────────────────────────────────────────

// rome-ignore lint/correctness/noUnusedVariables: run
function run(argv) {
	const pathArray = argv.map(pathObj => pathObj.toString());

	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const vaultDummy = vaultDummyFolder.replace(/^~/, app.pathTo("home folder");
	const obsidianJsonFilePath = app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
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
		app.doShellScript(`mkdir -p "${vaultDummyFolder}"`);
		app.doShellScript(`rm "${vaultDummyFolder}/"* || true`); // remove any existing symlinks
		app.doShellScript(`ln -sf '${firstFile}' '${vaultDummyFolder}'`);
		delay(0.1); // buffer so the new symlink is registered by Obsidian
		firstFile = vaultDummyFolder + firstFileBasename;
	}

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
