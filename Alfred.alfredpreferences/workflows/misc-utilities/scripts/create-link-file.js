#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

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

	let targetFolder = finder.pathTo("desktop");
	try {
		// errors when there is no open finder window
		targetFolder = decodeURIComponent(finder.insertionLocation().url()?.slice(7) || "");
		// biome-ignore lint/suspicious/noEmptyBlockStatements: intentional
	} catch (_error) {}

	const linkFilePath = `${targetFolder}/${safeTitle}.url`;
	const urlFileContent = ["[InternetShortcut]", `URL=${url}`, "IconIndex=0"].join("\n");
	writeToFile(linkFilePath, urlFileContent);

	finder.activate();
	finder.reveal(Path(linkFilePath));
	return;
}
