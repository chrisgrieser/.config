#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return " " + [clean, camelCaseSeperated, str].join(" ") + " ";
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const pluginLocation = $.getenv("plugin_installation_path");
	const masonLocation = $.getenv("mason_installation_path");
	let pluginArray = [];
	let masonArray = [];
	//───────────────────────────────────────────────────────────────────────────

	if (pluginLocation && fileExists(pluginLocation)) {
		pluginArray = app
			.doShellScript(
				`cd "${pluginLocation}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`,
			)
			.split("\r")
			.map((remote) => {
				const owner = remote.split("/")[3];
				const name = remote.split("/")[4].slice(0, -4); // remove ".git"
				const repo = `${owner}/${name}`;
				return {
					title: name,
					subtitle: owner,
					match: alfredMatcher(repo) + "plugin",
					arg: "https://github.com/" + repo,
					mods: {
						cmd: { arg: repo },
					},
					uid: repo,
				};
			});
	}
	if (masonLocation && fileExists(masonLocation)) {
		const masonRegistryPath = masonLocation + "/registries/github/mason-org/mason-registry/registry.json";
		const masonRegistry = JSON.parse(readFile(masonRegistryPath));
		const installedTools = app.doShellScript(`cd "${masonLocation}/bin" && ls -1`).split("\r");
		const masonIcon = "./mason-logo.png";
		const notForMason = { valid : false, subtitle : "🚫 Not for Mason Tool" };

		masonArray = masonRegistry
			.filter((/** @type {MasonPackage} */ tool) => installedTools.includes(tool.name))
			.map((/** @type {MasonPackage} */ tool) => {
				const categoryList = tool.categories.join(", ");
				const languages = tool.languages.length > 0 ? tool.languages.join(", ") : "";

				return {
					title: tool.name,
					subtitle: categoryList + "  ·  " + languages,
					match: alfredMatcher(tool.name) + categoryList,
					icon: { path: masonIcon },
					arg: tool.homepage,
					uid: tool.name,
					mods: {
						cmd: notForMason,
						shift: notForMason,
						ctrl: notForMason,
						fn: notForMason,
					},
				};
			});
	}

	return JSON.stringify({ items: [...masonArray, ...pluginArray] });
}
