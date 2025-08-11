#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const { url, title } = JSON.parse(argv[0]);
	const finder = Application("Finder");
	finder.includeStandardAdditions = true;

	const safeTitle = title
		.replaceAll("/", "-")
		.replace(/[\\$€§*#?!:;.,`'’‘"„“”«»’{}]/g, "")
		.replaceAll("&", "and")
		.replace(/ {2,}/g, " ")
		.slice(0, 50)
		.trim();

	let targetFolder;
	try {
		targetFolder = decodeURIComponent(finder.insertionLocation().url()?.slice(7) || "");
	} catch (_error) {
		// errors when there is no open finder window
		targetFolder = finder.pathTo("desktop");
	}

	const linkFilePath = `${targetFolder}/${safeTitle}.webloc`;
	const weblocContent = `
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>https://seb.se/var-kundservice</string>
</dict>
</plist>
`
	const urlFileContent = ["[InternetShortcut]", `URL=${url}`, "IconIndex=0"].join("\n");
	writeToFile(linkFilePath, urlFileContent);

	finder.activate();
	finder.reveal(Path(weblocFilePath));
}
