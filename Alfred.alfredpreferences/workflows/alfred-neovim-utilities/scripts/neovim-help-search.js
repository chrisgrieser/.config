#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMonths = (+new Date() - cacheObj.creationDate()) / 1000 / 60 / 60 / 24 / 30;
	return cacheAgeMonths > 12;
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const cacheFile = "./data/url-list.txt";

	// GUARD
	if (!fileExists(cacheFile)) {
		return JSON.stringify({
			items: [{ title: "Index missing. Create via ':nvim'", valid: false }],
		});
	}
	if (cacheIsOutdated(cacheFile)) {
		return JSON.stringify({
			items: [{ title: "Index outdated. Update via ':nvim'", valid: false }],
		});
	}

	const items = readFile(cacheFile)
		.split("\n")
		.map((url) => {
			const site = url.split("/").pop().split(".").shift();
			let name = url.split("#").pop().replaceAll("%3A", ":").replaceAll("'", "");
			let synonyms = "";

			const hasSynonyms = url.includes(",");
			const isSection = url.includes("\t");
			if (hasSynonyms) {
				synonyms = " " + url.split(",").pop();
				url = url.split(",").shift();
				name = name.split(",").shift();
			} else if (isSection) {
				url = url.split("\t").shift();
				name = name.replace("\t", " ");
			}

			// matcher improvements
			let matcher = alfredMatcher(name) + " " + site + " " + alfredMatcher(synonyms);
			if (name.startsWith("vim.")) matcher += " " + name.slice(4);
			if (site === "builtin") matcher += " fn";

			return {
				title: name + synonyms,
				match: matcher,
				subtitle: site,
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: items,
		cache: {
			seconds: 3600 * 24 * 7 * 4, // can take long, cache refreshed with other cache
			loosereload: true,
		},
	});
}
