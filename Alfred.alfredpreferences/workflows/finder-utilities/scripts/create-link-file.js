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

function browserTab() {
	const frontmostAppName = Application("System Events")
		.applicationProcesses.where({ frontmost: true })
		.name()[0];
	const frontmostApp = Application(frontmostAppName);
	// biome-ignore format: long
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
	const webkitVariants = ["Safari", "Webkit"];
	let title
	let url;
	if (chromiumVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		// @ts-expect-error
		url = frontmostApp.windows[0].activeTab.url();
		// @ts-expect-error
		title = frontmostApp.windows[0].activeTab.name();
	} else if (webkitVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		// @ts-expect-error
		url = frontmostApp.documents[0].url();
		// @ts-expect-error
		title = frontmostApp.documents[0].name();
	} else {
		app.displayNotification("", {
			withTitle: "You need a supported browser as your frontmost app",
			subtitle: "",
		});
		return;
	}
	return { url: url, title: title };
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let url = argv[0];
	let title;
	if (!url) {
		url = browserTab().url;
		title = browserTab().title;
	} else {
		const siteContent = httpRequest(url);
		try {
			title = siteContent
				.split("\n")
				.filter((/** @type {string[]} */ line) => line.includes("title="))[0]
				.split("=")[1];
		} catch (_error) {
			title = "Untitled";
		}
	}
	const safeTitle = title
		.replaceAll("/", "-")
		.replace(/[\\$€§*#?!:;.,`'’‘"„“”«»’{}]/g, "")
		.replaceAll("&", "and")
		.replace(/ {2,}/g, " ")
		.slice(0, 50)
		.trim();

	const baseFolder = $.getenv("base_folder");
	const linkFilePath = `${baseFolder}/${safeTitle}.url`;

	const urlFileContent = `[InternetShortcut]
URL=${url}
IconIndex=0`;

	writeToFile(linkFilePath, urlFileContent);
	Application("Finder").activate();
	Application("Finder").reveal(Path(linkFilePath));
}
