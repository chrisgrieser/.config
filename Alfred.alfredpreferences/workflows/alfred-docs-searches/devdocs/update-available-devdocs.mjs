#!/usr/bin/env node
// @ts-nocheck
import fs from "node:fs";
//──────────────────────────────────────────────────────────────────────────────

// TODO find a database for this?
const shortHands = {
	javascript: "js",
	typescript: "ts",
	hammerspoon: "hs",
	python: "py",
	numpy: "np",
	pandas: "pd",
	markdown: "md",
};

//──────────────────────────────────────────────────────────────────────────────
// INFO to be run from repo root
//──────────────────────────────────────────────────────────────────────────────

async function run() {
	const response = await fetch("https://devdocs.io/docs.json");
	const json = await response.json();

	// convert to hashmap to remove duplicates
	const allLangs = {};
	const noneItem = "<array> <string>-----</string> <string></string> </array>";
	const infoPlistPopup = [noneItem];
	for (const lang of json) {
		// allLangs json -> keyword-slug-map
		const id = lang.slug.replace(/~.*/, "");
		const keyword = shortHands[id] || id;
		if (allLangs[keyword]) continue; // do not add old versions of the same language
		allLangs[keyword] = lang.slug;

		// xml -> info.plist
		const keywordInfo = keyword !== id ? ` (keyword: ${keyword})` : "";
		const line = `<array> <string>${id}${keywordInfo}</string> <string>${keyword}</string> </array>`;
		infoPlistPopup.push(line);
	}

	// keyword-slug-map
	if (!fs.existsSync("./.github/")) fs.mkdirSync("./.github/");
	fs.writeFileSync("./.github/keyword-slug-map.json", JSON.stringify(allLangs));

	// info.plist: update to insert all languages as options
	/** @type {string[]} */
	const xmlLines = fs.readFileSync("./info.plist", "utf8").split("\n");

	// create multiple popups to select in Alfred config
	const numberOfPopups = 40;

	let newXmlLines = [];
	for (let i = 1; i <= numberOfPopups; i++) {
		const label = i === 1 ? "Enabled devdocs" : "";
		const number = i.toString().padStart(2, "0");

		newXmlLines = newXmlLines.concat([
			"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>pairs</key> <array>",
			...infoPlistPopup,
			`</array> </dict> <key>description</key> <string></string> <key>label</key> <string>${label}</string> <key>type</key> <string>popupbutton</string> <key>variable</key> <string>keyword_${number}</string> </dict>`,
		]);
	}

	const start = xmlLines.indexOf("\t<key>userconfigurationconfig</key>") + 2;
	const end = xmlLines.indexOf("\t</array>", start);
	xmlLines.splice(start, end - start, ...newXmlLines);
	fs.writeFileSync("./info.plist", xmlLines.join("\n"));
}

await run();
