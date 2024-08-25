#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	if (!str) return "";
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const baseUrl = "https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/";
	const pluginsUrl = "community-plugins.json";
	const downloadsUrl = "community-plugin-stats.json";

	const pluginJson = JSON.parse(httpRequest(baseUrl + pluginsUrl));
	const downloadsJson = JSON.parse(httpRequest(baseUrl + downloadsUrl));

	//───────────────────────────────────────────────────────────────────────────

	// add PLUGINS to the JSON
	const plugins = pluginJson
		.map(
			(
				/** @type {{ id: string; name: string; description: string; author: string; repo: string; }} */ plugin,
			) => {
				const { id, name, description, author, repo } = plugin;

				const githubURL = "https://github.com/" + repo;
				const openURI = `obsidian://show-plugin?id=${id}`;
				// enclosing link in  `<>` remove to the preview
				const discordUrl = `> [${name}](<https://obsidian.md/plugins?id=${id}>): ${description}`;

				const matcher =
					alfredMatcher(name) +
					alfredMatcher(author) +
					alfredMatcher(id) +
					alfredMatcher(description);

				// download bumbers
				const downloadCount = downloadsJson[id]?.downloads || 0;
				const downloadsStr = downloadCount ? downloadCount.toLocaleString("de-DE") + "↓  ·  " : "";
				const subtitle = downloadsStr + description + "  ·  by " + author;

				// create json for Alfred
				/** @type {AlfredItem & { downloadCount: number } } */
				const alfredItem = {
					title: name,
					subtitle: subtitle,
					arg: githubURL,
					quicklookurl: githubURL,
					uid: id,
					match: matcher,
					mods: {
						cmd: { arg: openURI },
						ctrl: { arg: id, subtitle: `⌃: Copy Plugin ID: "${id}"` },
						alt: { arg: discordUrl, subtitle: "⌥: Copy Link (discord ready)" },
					},
					downloadCount: downloadCount, // only to be able to sort
				};
				return alfredItem;
			},
		)
		.sort(
			(/** @type {{ downloadCount: number; }} */ a, /** @type {{ downloadCount: number; }} */ b) =>
				b.downloadCount - a.downloadCount,
		);

	return JSON.stringify({
		items: plugins,
		cache: {
			seconds: 3600 * 3, // 3 hours, bit quicker to catch new plugin admissions
			loosereload: true,
		},
	});
}
