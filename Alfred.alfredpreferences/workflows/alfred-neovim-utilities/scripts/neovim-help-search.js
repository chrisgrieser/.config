#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

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

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonArray = []

	const cacheFile = $.getenv("alfred_workflow_data") + "/url-list.txt";
	if (!fileExists(cacheFile)) {
		jsonArray.push({ title: "Index missing. Create via ':nvim'", valid: false });
		return JSON.stringify({ items: jsonArray });
	}

	readFile(cacheFile)
		.split("\n")
		.forEach(url => {
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

			jsonArray.push({
				title: name + synonyms,
				match: matcher,
				subtitle: site,
				arg: url,
				uid: url,
			});
		});

	return JSON.stringify({ items: jsonArray });
}
