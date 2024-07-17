#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ");
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const specialAnchors = {
	"uBlock Origin": "#1p-filters.html",
	"AdGuard AdBlocker": "#user-filter",
	// biome-ignore lint/style/useNamingConvention: not set by me
	Violentmonkey: "#scripts",
};

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const browser = $.getenv("browser");
	const browserVars = JSON.parse(readFile("./data/browser-vars.json"));
	const extensionPath = browserVars.extensionPath[browser].replace(/^~/, app.pathTo("home folder"));

	// GUARD
	const extensionManifests = app
		.doShellScript(`find "${extensionPath}" -name "manifest.json"`)
		.split("\r");
	if (extensionManifests.length === 0) {
		return JSON.stringify({
			items: [{ title: `No extensions found for ${browser}.` }],
		});
	}

	const extensions = extensionManifests.reduce((/** @type {AlfredItem[]} */ acc, manifestPath) => {
		const root = manifestPath.slice(0, -13);
		const id = root.replace(/.*Extensions\/(\w+)\/.*/, "$1");

		// GUARD duplicates can occur due to leftover folders from previous
		// extension versions
		const isDuplicate = acc.find((item) => item.uid === id);
		if (isDuplicate) return acc;

		const manifest = JSON.parse(readFile(manifestPath));

		// determine name
		let name = manifest.name;
		if (name.startsWith("__MSG_") && manifest.short_name) name = manifest.short_name;
		if (name.startsWith("__MSG_")) {
			const msg = JSON.parse(readFile(root + "_locales/en/messages.json"));
			name =
				msg.extensionName?.message ||
				msg.name?.message ||
				msg.extName?.message ||
				msg.appName?.message ||
				"[name not found]";
		}

		// determine options path
		let optionsPath = manifest.options_ui?.page || manifest.options_page || "";

		// EXCEPTIONS
		if (name === "Stylus") optionsPath = "manage.html";
		if (id === "bbojmeobdaicehcopocnfhaagefleiae") name = "OptiSearch";
		const anchor = specialAnchors[name] || "";

		// URLs
		const optionsUrl = `chrome-extension://${id}/${optionsPath}${anchor}`;
		const webstoreUrl = `https://chrome.google.com/webstore/detail/${id}`;
		const localFolder = extensionPath + "/" + id;

		// emoji/icon
		const emoji = optionsPath ? "" : " 🚫"; // indicate no options available
		const icon =
			manifest.icons["128"] ||
			manifest.icons["64"] ||
			manifest.icons["48"] ||
			manifest.icons["32"] ||
			manifest.icons["16"];
		const iconPath = root + icon;

		/** @type {AlfredItem} */
		const item = {
			title: name + emoji,
			match: alfredMatcher(name),
			icon: { path: iconPath },
			valid: optionsPath !== "",
			arg: optionsUrl,
			uid: id,
			mods: {
				alt: { arg: webstoreUrl },
				cmd: { arg: webstoreUrl },
				shift: { arg: localFolder },
			},
		};

		acc.push(item);
		return acc;
	}, []);
	return JSON.stringify({ items: extensions });
}
