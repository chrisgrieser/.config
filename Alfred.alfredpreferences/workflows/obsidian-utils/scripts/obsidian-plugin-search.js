#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function aMatcher(str) {
	const clean = str.replace(/[-_/]/g, " ");
	const joined = str.replaceAll(" ", "");
	return [clean, str, joined].join(" ") + " ";
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const baseUrl = "https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/";
	const pluginsFile = "community-plugins.json";
	const downloadsFile = "community-plugin-stats.json";
	const pluginJson = JSON.parse(httpRequest(baseUrl + pluginsFile));
	const downloadsJson = JSON.parse(httpRequest(baseUrl + downloadsFile));
	const vaultName = $.getenv("vault_path").replace(/^.*\/(.*)$/, "$1");

	// add PLUGINS to the JSON
	const plugins = pluginJson
		.map(
			(
				/** @type {{ id: string; name: string; description: string; author: string; repo: string; }} */ plugin,
			) => {
				const { id, name, description, author, repo } = plugin;

				const githubUrl = "https://github.com/" + repo;
				const obsidianPluginUri = `obsidian://show-plugin?vault=${vaultName}&id=${id}`;
				const matcher = aMatcher(name) + aMatcher(author) + aMatcher(description);

				// download numbers
				const downloadCount = downloadsJson[id]?.downloads || 0;
				const downloadsStr = downloadCount
					? downloadCount.toLocaleString("de-DE") + "↓  ·  "
					: "";
				const subtitle = downloadsStr + description + "  ·  by " + author;

				// create json for Alfred
				/** @type {AlfredItem & { downloadCount: number } } */
				const alfredItem = {
					title: name,
					subtitle: subtitle,
					arg: githubUrl,
					quicklookurl: githubUrl,
					uid: id,
					match: matcher,
					mods: {
						cmd: { arg: obsidianPluginUri },
						ctrl: { arg: id, subtitle: `⌃: Copy Plugin ID: "${id}"` },
						alt: { arg: githubUrl, subtitle: "⌥: Copy Link " },
					},
					downloadCount: downloadCount, // only for sorting below
				};
				return alfredItem;
			},
		)
		.sort(
			(
				/** @type {{ downloadCount: number; }} */ a,
				/** @type {{ downloadCount: number; }} */ b,
			) => b.downloadCount - a.downloadCount,
		);

	return JSON.stringify({
		items: plugins,
		cache: {
			seconds: 3600 * 3, // 3 hours, bit quicker to catch new plugin admissions
			loosereload: true,
		},
	});
}
