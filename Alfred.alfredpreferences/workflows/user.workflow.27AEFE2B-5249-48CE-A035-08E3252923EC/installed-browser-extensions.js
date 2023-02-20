#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

const browserConfig = "/Vivaldi/"; // lead the surrounding // for automation purposes
const extensionFolder = app.pathTo("home folder") + `/Library/Application Support/${browserConfig}/Default/Extensions`;

const jsonArray = app
	.doShellScript(`find "${extensionFolder}" -name "manifest.json"`)
	.split("\r")
	.map(manifestPath => {
		const root = manifestPath.slice(0, -13); /* eslint-disable-line no-magic-numbers */
		const id = root.replace(/.*Extensions\/(\w+)\/.*/, "$1");
		const manifest = JSON.parse(readFile(manifestPath));

		// determine name
		let name = manifest.name;
		if (name.startsWith("__MSG_") && manifest.short_name) name = manifest.short_name;
		if (name.startsWith("__MSG_")) {
			const messagesJson = JSON.parse(readFile(root + "_locales/en/messages.json"));
			if (messagesJson.extensionName?.message) name = messagesJson.extensionName.message;
			else if (messagesJson.name?.message) name = messagesJson.name.message;
			else "[name missing]";
		}

		// determine options path
		let optionsPath = "";
		if (manifest.options_ui?.page) optionsPath = manifest.options_ui.page;
		else if (manifest.options_page) optionsPath = manifest.options_page;
		const emoji = optionsPath ? " ⚙️" : "";
		const optionsUrl = `chrome-extension://${id}/${optionsPath}`;

		const iconPath = root + manifest.icons["128"];

		return {
			title: name + emoji,
			match: alfredMatcher(name),
			icon: { path: iconPath },
			valid: optionsPath !== "",
			arg: optionsUrl,
			uid: id,
		};
	});
JSON.stringify({ items: jsonArray });
