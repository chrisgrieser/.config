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
};

//──────────────────────────────────────────────────────────────────────────────

async function main() {
	const response = await fetch("https://devdocs.io/docs.json");

	// convert to hashmap to remove duplicates
	const allLangs = {};
	const noneItem = "<array> <string>none</string> <string></string> </array>";
	const infoPlistPopup = [noneItem];
	for (const lang of await response.json()) {
		// langs json
		const id = lang.slug.replace(/~.*/, "");
		const keyword = shortHands[id] || id;
		if (allLangs[keyword]) continue; // do not add old versions of the same language
		allLangs[keyword] = lang.slug;

		// xml
		const keywordInfo = keyword !== id ? ` (keyword: ${keyword})` : "";
		const line = `<array> <string>${id}${keywordInfo}</string> <string>${keyword}</string> </array>`;
		infoPlistPopup.push(line);
	}

	fs.writeFileSync("keyword-slug-map.json", JSON.stringify(allLangs));

	// update `info.plist` to insert all languages as options
	/** @type {string[]} */
	const xmlLines = fs.readFileSync("../info.plist", "utf8").split("\n");

	// create 9 new popups
	let newXmlLines = [];
	for (let i = 1; i <= 9; i++) {
		const label = i === 1 ? "Select devdoc" : "";
		newXmlLines = newXmlLines.concat([
			"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>pairs</key> <array>",
			...infoPlistPopup,
			`</array> </dict> <key>description</key> <string></string> <key>label</key> <string>${label}</string> <key>type</key> <string>popupbutton</string> <key>variable</key> <string>keyword_${i}</string> </dict>`,
		]);
	}

	const start = xmlLines.indexOf("\t<key>userconfigurationconfig</key>") + 2;
	const end = xmlLines.indexOf("\t</array>", start);
	xmlLines.splice(start, end - start, ...newXmlLines);
	fs.writeFileSync("../info.plist", xmlLines.join("\n"));
}

await main();
