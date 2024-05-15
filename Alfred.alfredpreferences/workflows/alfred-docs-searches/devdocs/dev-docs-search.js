#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// INFO
// All available languages: https://devdocs.io/docs.json
// Search Index: https://documents.devdocs.io/javascript/index.json
// Data: https://documents.devdocs.io/javascript/db.json
// However, all these seem undocumented. (source: https://github.com/luckasRanarison/nvim-devdocs)

/** @typedef {Object} DevDocsIndex
 * @property {{name: string, path: string, type: string}[]} entries
 * @property {{name: string, count: number, slug: string}[]} types
 */

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache Dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheAgeThresholdDays = 7;
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeDays = (+new Date() - +cacheObj.creationDate()) / 1000 / 60 / 60 / 24;
	return cacheAgeDays > cacheAgeThresholdDays;
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const keyword = $.getenv("alfred_workflow_keyword");
	console.log("keyword:", keyword);

	ensureCacheFolderExists();
	const mapCache = $.getenv("alfred_workflow_cache") + "/keyword-slug-map.json";
	if (cacheIsOutdated(mapCache)) {
		const mapUrl =
			"https://raw.githubusercontent.com/chrisgrieser/alfred-docs-searches/main/.github/keyword-slug-map.json";
		writeToFile(mapCache, httpRequest(mapUrl));
	}

	const keywordLanguageMap = JSON.parse(readFile(mapCache));
	const language = keywordLanguageMap[keyword];

	//───────────────────────────────────────────────────────────────────────────

	// INFO using custom cache mechanism, since Alfred's cache does not work with
	// multiple keywords: https://www.alfredforum.com/topic/21754-wrong-alfred-55-cache-used-when-using-alternate-keywords-like-foobar/#comment-113358
	const langIndexCache = `${$.getenv("alfred_workflow_cache")}/${language}.json`;

	if (cacheIsOutdated(langIndexCache)) {
		const iconpath = `./devdocs/icons/${keyword}.png`;
		const iconExists = fileExists(iconpath);

		const indexUrl = `https://documents.devdocs.io/${language}/index.json`;
		console.log("indexUrl:", indexUrl);

		/** @type {DevDocsIndex} */
		const response = JSON.parse(httpRequest(indexUrl));

		const entries = response.entries.map((entry) => {
			const url = `https://devdocs.io/${language}/${entry.path}`;

			/** @type{AlfredItem} */
			const item = {
				title: entry.name,
				subtitle: entry.type,
				match: camelCaseMatch(entry.name),
				quicklookurl: url,
				arg: url,
				uid: url,
			};
			if (iconExists) item.icon = { path: iconpath }; // icon defaults to devdocs icon
			return item;
		});

		writeToFile(langIndexCache, JSON.stringify({ items: entries }));
	}

	return readFile(langIndexCache);
}
