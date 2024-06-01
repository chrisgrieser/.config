#!/usr/bin/env osascript -l JavaScript

ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function run() {
	// CONFIG
	const home = app.pathTo("home folder");
	const karabinerJson = home + "/.config/karabiner/karabiner.json";
	const customRulesJson = home + "/.config/karabiner/assets/complex_modifications/";

	// GUARD yq is installed
	const yqNotInstalled = app.doShellScript("command -v yq || echo 'false'") === "false";
	if (yqNotInstalled) return "󱎘 yq is not installed.";

	// using `explode` to expand anchors & aliases: https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	app.doShellScript(`
		export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
		cd "$HOME/.config/karabiner/assets/complex_modifications/" || exit 1
		for f in *.yaml ; do
			f=$(basename "$f" .yaml)
			yq -o=json 'explode(.)' "$f.yaml" > "$f.json"
		done
	`);

	// compile new rules
	const customRules = [];
	const ruleFile = app.doShellScript(`ls "${customRulesJson}" | grep ".json"`).split("\r");
	for (const fileName of ruleFile) {
		const filePath = customRulesJson + fileName;
		const ruleSet = JSON.parse(readFile(filePath))?.rules;
		if (!ruleSet) return "󱎘 Parsing issue";
		for (const rule of ruleSet) {
			customRules.push(rule);
		}
		app.doShellScript(`rm "${filePath}"`); // delete leftover JSON
	}

	// insert new rules into karabiner config
	// INFO: the rules are added to the *first* profile in the profile list from Karabiner.
	const complexRules = JSON.parse(readFile(karabinerJson));
	complexRules.profiles[0].complex_modifications.rules = customRules;
	writeToFile(karabinerJson, JSON.stringify(complexRules));

	// validate
	const lintStatus = app.doShellScript(
		`"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --lint-complex-modifications "${karabinerJson}"`,
	);
	const msg = lintStatus.includes("ok") ? " Karabiner reloaded" : "󱎘 Karabiner config invalid";
	return msg; // notify via justfile output
}
