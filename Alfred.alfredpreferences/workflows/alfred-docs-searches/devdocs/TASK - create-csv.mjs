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

// <dict>
// 	<key>config</key>
// 	<dict>
// 		<key>default</key>
// 		<string></string>
// 		<key>pairs</key>
// 		<array>
// 			<array>
// 				<string>none</string>
// 				<string></string>
// 			</array>
// 			<array>
// 				<string>js (javascript)</string>
// 				<string>js</string>
// 			</array>
// 		</array>
// 	</dict>
// 	<key>type</key>
// 	<string>popupbutton</string>
// 	<key>variable</key>
// 	<string>keyword_2</string>
// </dict>

//──────────────────────────────────────────────────────────────────────────────

async function main() {
	const response = await fetch("https://devdocs.io/docs.json");

	// convert to hashmap to remove duplicates
	const allLangs = {};
	const newXmlLines = [];
	for (const lang of await response.json()) {
		const { name, slug } = lang;
		// langs json
		if (allLangs[name]) continue; // do not add old versions of the same language
		const cleanName = slug.replace(/~.*/g, "");
		const alfredKeyword = shortHands[cleanName] || cleanName;
		allLangs[alfredKeyword] = slug;

		// xml
		const line = `<array> <string>${alfredKeyword} (${name})</string> <string>${slug}</string> </array>`;
		newXmlLines.push(line);
	}

	const xmlLines = [
		"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>pairs</key> <array>",
		...newXmlLines,
		"</array> </dict> <key>description</key> <string></string> <key>label</key> <string>Select languages</string> <key>type</key> <string>popupbutton</string> <key>variable</key> <string>keyword_1</string> </dict>",
	];

	fs.writeFileSync("keyword-lang-map.json", JSON.stringify(allLangs));

	/** @type {string[]} */
	const lines = fs.readFileSync("../info.plist", "utf8").split("\n");
	const start = lines.indexOf("\t<key>userconfigurationconfig</key>") + 2;
	const end = lines.indexOf("\t</array>", start);
	lines.splice(start, end - start, ...xmlLines);
	fs.writeFileSync("../info.plist", lines.join("\n"));
}

await main();
