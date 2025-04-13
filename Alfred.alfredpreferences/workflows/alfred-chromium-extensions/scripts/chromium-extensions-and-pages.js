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

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const browser = $.getenv("browser");
	const browserVars = JSON.parse(readFile("./scripts/browser-vars.json"));
	const home = app.pathTo("home folder");
	const extensionPath = browserVars.extensionPath[browser].replace(/^~/, home);

	// GUARD browser not installed
	if (!fileExists(extensionPath)) {
		return JSON.stringify({
			items: [
				{
					title: browser + " not installed.",
					subtitle: "⏎: Open workflow configuration to select a different browser.",
					arg: `alfredpreferences://navigateto/workflows>workflow>${$.getenv("alfred_workflow_uid")}>userconfig>browser`,
				},
			],
		});
	}

	// SETTINGS
	const settings = JSON.parse(readFile("./scripts/all-chromium-browser-settings.json"));
	settings.push(...browserVars.extraSettingsPages[browser]);
	const iconPath = browserVars.appIcon[browser];
	for (const page of settings) {
		page.uid = page.arg;
		page.icon = { path: iconPath };
		page.mods = {
			cmd: { valid: false, subtitle: "" }, // disable opening in Chrome Webstore
			shift: { valid: false, subtitle: "" }, // disable open local folder
		};
	}

	// EXTENSIONS
	const extensions = app
		.doShellScript(`find "${extensionPath}" -name "manifest.json" -maxdepth 3 -mindepth 3`)
		.split("\r")
		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
		.reduce((/** @type {AlfredItem[]} */ acc, manifestPath) => {
			const root = manifestPath.slice(0, -13);
			const id = root.replace(/.*Extensions\/(\w+)\/.*/, "$1");

			// GUARD duplicates can occur due to leftover folders from previous
			// extension versions
			const isDuplicate = acc.find((item) => item.uid === id);
			if (isDuplicate) return acc;

			const manifest = JSON.parse(readFile(manifestPath));

			// determine name
			let name = manifest.name;
			const hasPrettierShortname =
				name.startsWith("__MSG_") &&
				manifest.short_name &&
				!manifest.short_name.startsWith("__MSG_");
			if (hasPrettierShortname) {
				name = manifest.short_name;
			} else if (name.startsWith("__MSG_")) {
				let msgsFile = root + "_locales/en/messages.json";
				if (!fileExists(msgsFile)) msgsFile = root + "_locales/en_US/messages.json";
				if (fileExists(msgsFile)) {
					const msg = JSON.parse(readFile(msgsFile));
					const nameKey = name.replace(/__MSG_(.*)__/, "$1");
					name = msg[nameKey]?.message || manifest.name;
				}
			}

			// determine options or popup path
			let optionsPath =
				manifest.options_ui?.page ||
				manifest.options_page ||
				manifest.browser_action?.default_popup ||
				manifest.action?.default_popup ||
				"";

			// EXCEPTIONS where a different page/name is more convenient or more correct
			if (name === "Stylus") optionsPath = "manage.html";
			if (name === "Redirector") optionsPath = "redirector.html";
			if (name === "Violentmonkey") optionsPath += "#scripts";

			// URLs
			const optionsUrl = `chrome-extension://${id}/${optionsPath}`;
			const webstoreUrl = "https://chrome.google.com/webstore/detail/" + id;
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

	return JSON.stringify({ items: [...settings, ...extensions] });
}
