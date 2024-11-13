#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const originalSites = {
	css: "https://developer.mozilla.org/en-US/docs/Web/CSS/",
	javascript: "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/",
	html: "https://developer.mozilla.org/en-US/docs/Web/HTML/",
	dom: "https://developer.mozilla.org/en-US/docs/Web/API/",
	jsdoc: "https://jsdoc.app/",
	typescript: "https://www.typescriptlang.org/",
	electron: "https://www.electronjs.org/docs/latest/",
	python: "https://docs.python.org/{{version}}/",
	git: "https://git-scm.com/docs/",
	lua: "https://www.lua.org/manual/{{version}}/manual.html",
	hammerspoon: "https://www.hammerspoon.org/docs/",
	// biome-ignore lint/style/useNamingConvention: not by me
	browser_support_tables: "https://caniuse.com/",
	node: "https://nodejs.org/api/",
	moment: "https://momentjs.com/docs/#/",
	npm: "https://docs.npmjs.com/",
	esbuild: "https://esbuild.github.io/",
};

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const url = argv[0];
	let [_, topic, version, site] = url.match(/.*devdocs\.io\/([^/~]*)(?:~(.*?))?\/(.+)/) || [];
	let sourcePage = originalSites[topic];
	const useSourcePageIfAvailable = $.getenv("use_source_page_if_available") === "1";

	// OPEN ON DEVDOCS
	if (!(useSourcePageIfAvailable && sourcePage)) {
		app.openLocation(url);
		return;
	}

	// OPEN AT ORIIGNAL
	if (version) sourcePage = sourcePage.replace("{{version}}", version);

	// a bunch of annoying special cases…
	if (topic === "lua") site = site.replace("index", "");
	if (topic === "node") site = site.replace("#", ".html#");
	if (topic === "moment") site = site.replace("index#/", "");

	const sourceUrl = sourcePage + site;
	app.openLocation(sourceUrl);
}
