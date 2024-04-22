#!/usr/bin/env node
// @ts-nocheck
import fs from "node:fs";
//──────────────────────────────────────────────────────────────────────────────

const shortHands = {
	javascript: "js",
	typescript: "ts",
	python: "py",
	hammerspoon: "hs",
};

// to be run from repo root
const paths = {
	infoPlist: "./info.plist",
	keywordSlugMap: "./.github/keyword-slug-map.json",
};

//──────────────────────────────────────────────────────────────────────────────

async function run() {
	const response = await fetch("https://devdocs.io/docs.json");
	const json = await response.json();

	// convert to hashmap to remove duplicates
	const allLangs = {};
	const noneItem = "<array> <string>-----</string> <string></string> </array>";
	const infoPlistPopup = [noneItem];
	for (const lang of json) {
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

	fs.writeFileSync(paths.keywordSlugMap, JSON.stringify(allLangs));

	// update `info.plist` to insert all languages as options
	/** @type {string[]} */
	const xmlLines = fs.readFileSync(paths.infoPlist, "utf8").split("\n");

	// create multiple popups to select in Alfred config
	const popupNumber = 20;
	let newXmlLines = [];
	for (let i = 1; i <= popupNumber; i++) {
		const label = i === 1 ? "Enabled devdocs" : "";
		const number = i.toString().padStart(2, "0");

		newXmlLines = newXmlLines.concat([
			"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>pairs</key> <array>",
			...infoPlistPopup,
			`</array> </dict> <key>description</key> <string></string> <key>label</key> <string>${label}</string> <key>type</key> <string>popupbutton</string> <key>variable</key> <string>keyword_${number}</string> </dict>`,
		]);
	}

	// {var:keyword_01}||{var:keyword_02}||{var:keyword_03}||{var:keyword_04}||{var:keyword_05}||{var:keyword_06}||{var:keyword_07}||{var:keyword_08}||{var:keyword_09}||{var:keyword_10}||{var:keyword_11}||{var:keyword_12}||{var:keyword_13}||{var:keyword_14}||{var:keyword_15}||{var:keyword_16}||{var:keyword_17}||{var:keyword_18}||{var:keyword_19}||{var:keyword_20}
	const start = xmlLines.indexOf("\t<key>userconfigurationconfig</key>") + 2;
	const end = xmlLines.indexOf("\t</array>", start);
	xmlLines.splice(start, end - start, ...newXmlLines);
	fs.writeFileSync(paths.infoPlist, xmlLines.join("\n"));
}

await run();
