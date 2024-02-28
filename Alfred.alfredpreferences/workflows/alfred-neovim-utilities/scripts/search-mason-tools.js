#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return " " + [clean, camelCaseSeparated, str].join(" ") + " ";
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @typedef {Object} MasonPackage
 * @property {string} homepage
 * @property {string} name
 * @property {string[]} categories
 * @property {string[]} languages
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// GUARD
	const masonLocation = $.getenv("mason_installation_path");
	if (!masonLocation) {
		return JSON.stringify({
			items: [
				{
					title: "🚫 Mason Installation path not set.",
					subtitle: "Set the path in the Alfred workflow configuration.",
					valid: false,
				},
			],
		});
	}
	if (!fileExists(masonLocation)) {
		return JSON.stringify({
			items: [{ title: "🚫 Mason Installation does not exist.", valid: false }],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	const masonRegistryPath =
		masonLocation + "/registries/github/mason-org/mason-registry/registry.json";
	const masonRegistry = JSON.parse(readFile(masonRegistryPath));
	const installedTools = app.doShellScript(`cd "${masonLocation}/packages" && ls -1`).split("\r");
	const masonIcon = "./mason-logo.png";

	/** @type AlfredItem[] */
	const availableTools = masonRegistry.map((/** @type {MasonPackage} */ tool) => {
		const installedIcon = installedTools.includes(tool.name) ? "✅ " : "";
		const categoryList = tool.categories.join(", ");
		const languages = tool.languages.length > 0 ? tool.languages.join(", ") : "";
		const separator = languages && categoryList ? "  ·  " : "";
		const subtitle = categoryList + separator + languages;

		return {
			title: installedIcon + tool.name,
			subtitle: subtitle,
			match: alfredMatcher(tool.name) + categoryList + " " + languages,
			arg: tool.homepage,
			quicklookurl: tool.homepage,
			icon: { path: masonIcon },
		};
	});
	return JSON.stringify({
		items: availableTools,
		cache: {
			seconds: 300, // faster, to update install icons
			loosereload: true,
		},
	});
}
