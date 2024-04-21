#!/usr/bin/env node
// @ts-nocheck
import fs from "node:fs";

//──────────────────────────────────────────────────────────────────────────────

const shortHands = {
	javascript: "js",
	typescript: "ts",
	python: "py",
	hammerspoon: "hs",
	// biome-ignore lint/style/useNamingConvention: input formatted like this
	gnu_make: "make",
}

async function main() {
	const response = await fetch("https://devdocs.io/docs.json");

	// convert to hashmap to remove duplicates
	const allLangs = {}
	for (const lang of (await response.json())) {
		// do not add old versions of the same language
		if (allLangs[lang.name]) continue;

		const cleanName = lang.slug.replace(/~.*/g, "");
		const alfredKeyword = shortHands[cleanName] || cleanName;
		allLangs[alfredKeyword] = lang.slug;
	}

	fs.writeFileSync("keyword-lang-map.json", JSON.stringify(allLangs));
}

await main();
