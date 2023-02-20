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
		const root = manifestPath.slice(0, -13) /* eslint-disable-line no-magic-numbers */
		const id = root.replace(/.*Extensions\/(\w+)\/.*/, "$1");
		const manifest = JSON.parse(readFile(manifestPath));
		const description = manifest.description.startsWith("__MSG_") ? "" : manifest.description;

		let name = manifest.name;
		if (name.startsWith("__MSG_") && manifest.short_name) name = manifest.short_name;
		if (name.startsWith("__MSG_")) {
			const messagesJson = JSON.parse(readFile(root + "_locales/en/messages.json"));
			name = messagesJson.extensionName?.message ? messagesJson.extensionName.message : "[name missing]";
		}

		const iconPath = root + manifest.icons["128"];
		const optionsSubPath = manifest.options_ui?.page ? manifest.options_ui.page : "";
		const emoji = optionsSubPath === "" ? "" : " ⚙️";

		return {
			title: name,
			subtitle: emoji,
			match: alfredMatcher(name),
			icon: { path: iconPath },
			valid: optionsSubPath === "",
			arg: id,
			uid: id,
		};
	});
JSON.stringify({ items: jsonArray });
