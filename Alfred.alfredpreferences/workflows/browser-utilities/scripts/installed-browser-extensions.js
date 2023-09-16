#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const browserDefaultsPath = argv[0];
	const extensionFolder =
		app.pathTo("home folder") + `/Library/Application Support/${browserDefaultsPath}/Default/Extensions`;

	const extensions = app
		.doShellScript(`find "${extensionFolder}" -name "manifest.json"`)
		.split("\r")
		.map((manifestPath) => {
			const root = manifestPath.slice(0, -13);
			const id = root.replace(/.*Extensions\/(\w+)\/.*/, "$1");
			const manifest = JSON.parse(readFile(manifestPath));

			// determine name
			let name = manifest.name;
			if (name.startsWith("__MSG_") && manifest.short_name) name = manifest.short_name;
			if (name.startsWith("__MSG_")) {
				const msg = JSON.parse(readFile(root + "_locales/en/messages.json"));
				name = msg.extensionName?.message || msg.name?.message || msg.extName?.message || msg.appName?.message || "[name not found]";
			}

			// determine options path
			const optionsPath = manifest.options_ui?.page || manifest.options_page || "";
			const optionsUrl = `chrome-extension://${id}/${optionsPath}`;
			const webstoreUrl = `https://chrome.google.com/webstore/detail/${id}`;
			const localFolder = extensionFolder + "/" + id;

			// emoji/icon
			const emoji = optionsPath ? "" : " 🚫"; // indicate no options available
			const icon = manifest.icons["128"] || manifest.icons["64"] || manifest.icons["48"];
			const iconPath = root + icon;

			return {
				title: name + emoji,
				match: alfredMatcher(name),
				icon: { path: iconPath },
				valid: optionsPath !== "",
				arg: optionsUrl,
				uid: id,
				mods: {
					alt: { arg: webstoreUrl },
					cmd: { arg: webstoreUrl },
					fn: { arg: localFolder },
				},
			};
		});
	return JSON.stringify({ items: extensions });
}
