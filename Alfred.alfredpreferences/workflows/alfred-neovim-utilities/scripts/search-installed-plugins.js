#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

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

const gitEnding = /\.git$/;
const githubUrlStart = /https?:\/\/github.com\//;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const pluginInstallPath = $.getenv("plugin_installation_path");
	const masonLocation = $.getenv("mason_installation_path");

	/** @type {AlfredItem[]} */
	let pluginArray = [];
	let masonArray = [];

	if (pluginInstallPath && fileExists(pluginInstallPath)) {
		const shellCmd = `cd "${pluginInstallPath}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`;
		pluginArray = app
			.doShellScript(shellCmd)
			.split("\r")
			.map((remote) => {
				const url = remote.replace(gitEnding, "");
				const repo = url.replace(githubUrlStart, "");
				const [owner, name] = repo.split("/");
				const installPath = $.getenv("plugin_installation_path") + "/" + name;

				return {
					title: name,
					subtitle: owner,
					match: alfredMatcher(repo) + "plugin",
					arg: url,
					quicklookurl: url,
					mods: {
						cmd: { arg: repo },
						fn: { arg: installPath },
					},
					uid: repo,
				};
			});
	}
	if (masonLocation && fileExists(masonLocation)) {
		const masonRegistryPath =
			masonLocation + "/registries/github/mason-org/mason-registry/registry.json";
		const masonRegistry = JSON.parse(readFile(masonRegistryPath));
		const installedTools = app.doShellScript(`cd "${masonLocation}/packages" && ls -1`).split("\r");
		const masonIcon = "./mason-logo.png";

		masonArray = masonRegistry
			.filter((/** @type {MasonPackage} */ tool) => installedTools.includes(tool.name))
			.map((/** @type {MasonPackage} */ tool) => {
				const categoryList = tool.categories.join(", ");
				const languages = tool.languages.length > 0 ? tool.languages.join(", ") : "";
				const separator = languages && categoryList ? "  ·  " : "";
				const subtitle = categoryList + separator + languages;
				const installPath = masonLocation + "/packages/" + tool.name;

				return {
					title: tool.name,
					subtitle: subtitle,
					match: alfredMatcher(tool.name) + categoryList,
					icon: { path: masonIcon },
					arg: tool.homepage,
					quicklookurl: tool.homepage,
					uid: tool.name,
					mods: {
						cmd: { valid: false, subtitle: "🚫 Not for Mason Tool" },
						shift: { valid: false, subtitle: "🚫 Not for Mason Tool" },
						fn: { arg: installPath },
					},
				};
			});
	}

	return JSON.stringify({
		items: [...pluginArray, ...masonArray],
		cache: {
			seconds: 15, // faster, since installs can change
			loosereload: true,
		},
	});
}
