#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const vaultPath = $.getenv("vault_path");
	const vaultNameEnc = encodeURIComponent(vaultPath.replace(/.*\//, ""));

	// VALIDATE that `Advanced URI` is installed and enabled
	const configFolder = $.getenv("config_folder");
	const aUriInstalled = fileExists(`${vaultPath}/${configFolder}/plugins/obsidian-advanced-uri`);
	const pluginList = readFile(`${vaultPath}/${configFolder}/community-plugins.json`);
	const aUriEnabled = JSON.parse(pluginList).includes("obsidian-advanced-uri");
	if (!aUriInstalled || !aUriEnabled) {
		app.displayNotification("", {
			withTitle: "Error",
			subtitle: `"Advanced URI" plugin not installed or not enabled.`,
		});
		return;
	}

	// determine input
	const input = (argv[0] || "").trim(); // trim to remove trailing \n
	const relativePath = (input.split("#")[0] || "").split(":")[0] || "";
	const heading = input.split("#")[1];
	const lineNum = input.split(":")[1]; // used by `oe` external link search to open at line

	// DOCS https://vinzent03.github.io/obsidian-advanced-uri/concepts/navigation_parameters#open-mode
	const openMode = $.NSProcessInfo.processInfo.environment.objectForKey("open_mode").js;

	// construct URI scheme
	// https://help.obsidian.md/Extending+Obsidian/Obsidian+URI
	// https://vinzent03.github.io/obsidian-advanced-uri/actions/navigation
	const urlComponents = [
		"obsidian://advanced-uri?",
		`vault=${vaultNameEnc}`,
		`&filepath=${encodeURIComponent(relativePath)}`,
		heading ? "&heading=" + encodeURIComponent(heading) : "",
		lineNum ? "&line=" + encodeURIComponent(lineNum) : "",
		openMode ? "&openmode=" + openMode : "",
	];
	const uri = urlComponents.join("");

	// OPEN FILE
	// - Delay opening URI scheme until Obsidian is running, URIs do not open
	//   reliably when vault is not open. (also applies to Obsidian core's URIs)
	// - Do not count windows, since it requires somewhat the macOS accessibility
	//   perrmission, which often appears to be bit buggy (see #191).
	if (!Application("Obsidian").running()) {
		Application("Obsidian").launch();
		delay(1.5);
	}
	app.openLocation(uri);
	console.log("URI opened:", uri);
	return;
}