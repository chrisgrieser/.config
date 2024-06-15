#!/usr/bin/env node
//──────────────────────────────────────────────────────────────────────────────
// INFO
// - needs to be run from repo root: `node ./scripts/devdocs/update-devdocs.mjs`
// - updates which devdocs are available, and also the versions of devdocs
//   (automatically switches to the latest version)
// - WARN this overwrites all available workflow configuration, so changes need
//   to be added here manually, such as the field for using specific devdocs
//   versions.
//──────────────────────────────────────────────────────────────────────────────
// biome-ignore lint/correctness/noNodejsModules: unsure how to fix this
import fs from "node:fs";
//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const aliases = {
	// aliases added on top of the ones from devdocs
	hammerspoon: "hs",

	// PENDING https://github.com/freeCodeCamp/devdocs/issues/2210
	// devdocs aliases https://devdocs.io/help#aliases
	angular: "ng",
	angularjs: "ng", // removed `.`
	backbone: "bb", // removed `.js`
	coffeescript: "cs",
	crystal: "cr",
	elixir: "ex",
	javascript: "js",
	julia: "jl",
	jquery: "$",
	knockout: "ko", // removed `.js`
	kubernetes: "k8s",
	less: "ls",
	lodash: "_",
	marionette: "mn",
	markdown: "md",
	matplotlib: "mpl",
	modernizr: "mdr",
	moment: "mt", // removed `.js`
	openjdk: "java",
	nginx: "ngx",
	numpy: "np",
	pandas: "pd",
	postgresql: "pg",
	python: "py",
	rails: "ror", // ruby.on.rails -> tails
	ruby: "rb",
	rust: "rs",
	sass: "scss",
	tensorflow: "tf",
	typescript: "ts",
	underscore: "_", // removed `.js`
};

//──────────────────────────────────────────────────────────────────────────────

const slugRegex = /~.*/;

// add extra line for workflow versions, since it's overridden further below
const extraWorkflowConfig = [
	"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>required</key> <false/> <key>trim</key> <true/> <key>verticalsize</key> <integer>3</integer> </dict> <key>description</key> <string>one per line; see to the right for explanations</string> <key>label</key> <string>pinned devdocs versions</string> <key>type</key> <string>textarea</string> <key>variable</key> <string>select_versions</string> </dict>",
];

async function run() {
	const response = await fetch("https://devdocs.io/docs.json");
	const json = await response.json();

	// convert to hashmap to remove duplicates
	/** @type {Record<string, string>} */
	const allLangs = {};
	const noneItem = "<array> <string>-----</string> <string></string> </array>";
	const infoPlistPopup = [noneItem];
	for (const lang of json) {
		// allLangs json -> keyword-slug-map
		const id = lang.slug.replace(slugRegex, "");
		const keyword = aliases[id] || id;
		if (allLangs[keyword]) continue; // do not add old versions of the same language
		allLangs[keyword] = lang.slug;

		// xml -> info.plist
		const label = keyword !== id ? `${id} (keyword: ${keyword})` : id;
		const line = `<array> <string>${label}</string> <string>${keyword}</string> </array>`;
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

	/** @type {string[]} */
	const newXmlLines = [];
	for (let i = 1; i <= numberOfPopups; i++) {
		const label = i === 1 ? "Enabled devdocs" : "";
		const number = i.toString().padStart(2, "0");

		newXmlLines.push(
			"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>pairs</key> <array>",
			...infoPlistPopup,
			`</array> </dict> <key>description</key> <string></string> <key>label</key> <string>${label}</string> <key>type</key> <string>popupbutton</string> <key>variable</key> <string>keyword_${number}</string> </dict>`,
		);
	}
	newXmlLines.push(...extraWorkflowConfig);

	const start = xmlLines.indexOf("\t<key>userconfigurationconfig</key>") + 2;
	const end = xmlLines.indexOf("\t</array>", start);
	xmlLines.splice(start, end - start, ...newXmlLines);
	fs.writeFileSync("./info.plist", xmlLines.join("\n"));
}

await run();
