#!/usr/bin/env node
//──────────────────────────────────────────────────────────────────────────────
// INFO
// - needs to be run from repo root: `node ./scripts/devdocs/update-devdocs.mjs`
// - updates which devdocs are available, and also the versions of devdocs
//   (automatically switches to the latest version)
// - WARN this overwrites all available workflow configuration, so changes to
//   the workflow configuration need to be added here manually, such as the
//   field for using specific devdocs versions.
//──────────────────────────────────────────────────────────────────────────────
import fs from "node:fs";

/** @type {Record<string, string>} */
const customAliases = {
	hammerspoon: "hs",
	// biome-ignore lint/style/useNamingConvention: not set by me
	browser_support_tables: "cani",
	matplotlib: "plt", // preferring the conventional `plt` over `mlp` https://docs.astral.sh/ruff/settings/#lint_flake8-import-conventions_aliases
};

// IMPORTANT extra lines for pinned workflow versions and opening at original
// page, since it's overridden otherwise
const extraWorkflowConfig = [
	"<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>required</key> <false/> <key>trim</key> <true/> <key>verticalsize</key> <integer>3</integer> </dict> <key>description</key> <string>one per line; see to the right for explanations</string> <key>label</key> <string>pinned devdocs versions</string> <key>type</key> <string>textarea</string> <key>variable</key> <string>select_versions</string> </dict>",
	"<dict> <key>config</key> <dict> <key>default</key> <false/> <key>required</key> <false/> <key>text</key> <string></string> </dict> <key>description</key> <string>Only available for a few sites. PRs welcome.</string> <key>label</key> <string>open at original</string> <key>type</key> <string>checkbox</string> <key>variable</key> <string>use_source_page_if_available</string> </dict>",
	'<dict> <key>config</key> <dict> <key>default</key> <string></string> <key>placeholder</key> <string></string> <key>required</key> <false/> <key>trim</key> <true/> </dict> <key>description</key> <string>Shared keyword prefix for DevDocs searches. If set to "dd" , will search the bash documentation via "ddbash" instead of "bash". Leave empty to not use any such prefix.</string> <key>label</key> <string>DevDocs prefix</string> <key>type</key> <string>textfield</string> <key>variable</key> <string>shared_devdocs_prefix</string> </dict>',
];

//──────────────────────────────────────────────────────────────────────────────

async function run() {
	// alternative: https://documents.devdocs.io/docs.json
	const response = await fetch("https://devdocs.io/docs.json");
	const json = await response.json();

	/** @type {Record<string, string>} */
	const allLangs = {};
	const noneItem = "<array> <string>-----</string> <string></string> </array>";
	const infoPlistPopup = [noneItem];
	for (const lang of json) {
		// using a better man page search of our own
		if (lang.name === "Linux man pages") continue;

		const id = lang.slug.replace(/~.*/, ""); // remove version suffix
		const keyword = customAliases[id] || lang.alias || id; // custom -> devdocs -> id

		// skip duplicates
		// (assuming the JSON puts newer version on top, skips older versions)
		if (allLangs[keyword]) continue;
		allLangs[keyword] = lang.slug;

		// xml -> info.plist
		const label = keyword !== id ? `${id} (keyword: ${keyword})` : id;
		const line = `<array> <string>${label}</string> <string>${keyword}</string> </array>`;
		infoPlistPopup.push(line);
	}

	// keyword-slug-map
	if (!fs.existsSync("./.github/caches/")) fs.mkdirSync("./.github/caches/", { recursive: true });
	const beautifiedForBetterDiff = JSON.stringify(allLangs, null, 2);
	fs.writeFileSync("./.github/caches/devdocs-keyword-slug-map.json", beautifiedForBetterDiff);

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
