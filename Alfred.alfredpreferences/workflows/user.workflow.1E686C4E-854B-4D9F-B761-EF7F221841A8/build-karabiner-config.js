#!/usr/bin/env osascript -l JavaScript
let karabinerJSON = "~/.config/karabiner/karabiner.json";
let customRulesJSONlocation = "~/.config/karabiner/assets/complex_modifications/";
//------------------------------------------------------------------------------
const app = Application.currentApplication();
app.includeStandardAdditions = true;
ObjC.import("Foundation");
function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}
function writeToFile(text, file) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}
//------------------------------------------------------------------------------
karabinerJSON = karabinerJSON.replace(/^~/, app.pathTo("home folder"));
customRulesJSONlocation = customRulesJSONlocation.replace(/^~/, app.pathTo("home folder"));

const customRules = [];
app.doShellScript(`ls "${customRulesJSONlocation}" | grep ".json"`)
	.split("\r")
	.forEach(fileName => {
		const filePath = customRulesJSONlocation + fileName;
		const ruleSet = JSON.parse(readFile(filePath)).rules;
		ruleSet.forEach(rule => customRules.push(rule) );
	});

const complexRules = JSON.parse(readFile(karabinerJSON));

// INFO: the rules are added to the *first* profile in the profile list from Karabiner.
complexRules.profiles[0].complex_modifications.rules = customRules;

writeToFile(JSON.stringify(complexRules), karabinerJSON);
const lintStatus = app.doShellScript(`"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --lint-complex-modifications "${karabinerJSON}"`).trim();

if (lintStatus === "ok") "✅ Karabiner Config Build";
else "🛑 Karabiner Build Error";
