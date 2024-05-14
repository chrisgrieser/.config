#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let url = argv[0];
	const finder = Application("Finder");

	let title;
	if (url) {
		const siteContent = httpRequest(url);
		try {
			title = siteContent
				.split("\n")
				.filter((line) => line.includes("title="))[0]
				.split("=")[1];
		} catch (_error) {
			title = "Untitled";
		}
	} else {
		const tab = browserTab();
		if (!tab) return;
		url = tab.url;
		title = tab.title;
	}
	const safeTitle = title
		.replaceAll("/", "-")
		.replace(/[\\$€§*#?!:;.,`'’‘"„“”«»’{}]/g, "")
		.replaceAll("&", "and")
		.replace(/ {2,}/g, " ")
		.slice(0, 50)
		.trim();

	const targetFolder =
		decodeURIComponent(finder.insertionLocation()?.url()?.slice(7) || "") ||
		app.pathTo("home folder") + "/Desktop";
	const linkFilePath = `${targetFolder}/${safeTitle}.url`;

	const urlFileContent = ["[InternetShortcut]", `URL=${url}`, "IconIndex=0"].join("\n");
	writeToFile(linkFilePath, urlFileContent);

	finder.activate();
	finder.reveal(Path(linkFilePath));
	return;
}
