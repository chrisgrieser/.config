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

/** @param {number} num */
function insert1000sep(num) {
	let numStr = num.toString();
	let acc = "";
	while (numStr.length > 3) {
		acc = "." + numStr.slice(-3) + acc;
		numStr = numStr.slice(0, -3);
	}
	return numStr + acc;
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
function run() {
	const baseUrl = "https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/";
	const pluginsUrl = "community-plugins.json";
	const downloadsUrl = "community-plugin-stats.json";

	const pluginJson = JSON.parse(httpRequest(baseUrl + pluginsUrl));
	const downloadsJson = JSON.parse(httpRequest(baseUrl + downloadsUrl));

	const depre = JSON.parse(readFile("./scripts/deprecated-plugins.json"));
	const deprecatedPlugins = [...depre.sherlocked, ...depre.dysfunct, ...depre.deprecated];

	//───────────────────────────────────────────────────────────────────────────

	// add PLUGINS to the JSON
	const plugins = pluginJson
		.reverse() // show new plugins on top
		.map(
			(
				/** @type {{ id: string; name: string; description: string; author: string; repo: string; }} */ plugin,
			) => {
				const { id, name, description, author, repo } = plugin;

				const githubURL = "https://github.com/" + repo;
				const openURI = `obsidian://show-plugin?id=${id}`;
				// Discord accepts simple markdown, the enclosing, the enclosing `<>`
				// remove the preview
				const discordUrl = `> [${name}](<https://obsidian.md/plugins?id=${id}>): ${description}`;

				// Download Numbers
				let downloadsStr = "";
				if (downloadsJson[id]) {
					const downloads = downloadsJson[id].downloads;
					downloadsStr = insert1000sep(downloads) + "↓  ·  ";
				}

				// check whether already installed / deprecated
				const icons = deprecatedPlugins.includes(id) ? " ⚠️" : "";
				const subtitleIcons = deprecatedPlugins.includes(id) ? "deprecated · " : "";

				// Better matching for some plugins
				const matcher =
					alfredMatcher(name) +
					alfredMatcher(author) +
					alfredMatcher(id) +
					alfredMatcher(description);
				const subtitle = downloadsStr + subtitleIcons + description + "  ·  by " + author;

				// create json for Alfred
				/** @type {AlfredItem} */
				const alfredItem = {
					title: name + icons,
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
				};
				return alfredItem;
			},
		);

	return JSON.stringify({
		items: plugins,
		cache: {
			seconds: 3600 * 3, // 3 hours, bit quicker to catch new plugin admissions
			loosereload: true,
		},
	});
}
