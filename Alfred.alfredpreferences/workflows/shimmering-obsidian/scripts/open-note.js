#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const vaultPath = $.getenv("vault_path");
	const vaultNameEnc = encodeURIComponent(vaultPath.replace(/.*\//, ""));

	const input = (argv[0] || "").trim(); // trim to remove trailing \n
	const relativePath = (input.split("#")[0] || "").split(":")[0] || "";
	const heading = input.split("#")[1];
	const lineNum = input.split(":")[1]; // used by `oe` external link search to open at line

	// construct URI scheme, preferring Obsidian's own URI since it works without
	// Obsidian being open; advanced-URI only needed for opening by file or line
	// https://help.obsidian.md/Extending+Obsidian/Obsidian+URI
	// https://vinzent03.github.io/obsidian-advanced-uri/actions/navigation
	const useAdvancedUri = heading || lineNum;
	const urlSchemeBase = useAdvancedUri
		? `obsidian://vault=${vaultNameEnc}&file=`
		: `obsidian://advanced-uri?vault=${vaultNameEnc}&filepath=`;
	const urlScheme =
		urlSchemeBase +
		encodeURIComponent(relativePath) +
		(heading ? "&heading=" + encodeURIComponent(heading) : "") +
		(lineNum ? "&line=" + encodeURIComponent(lineNum) : "");
	console.log("❗ urlScheme:", urlScheme);

	// OPEN FILE
	app.openLocation(urlScheme);
	return;
}
