#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {object} WorkflowVariable
 * @property {object} config
 * @property {string} config.default
 * @property {string} config.placeholder
 * @property {boolean} config.required
 * @property {boolean} config.trim
 * @property {string} description
 * @property {string} label
 * @property {string} type
 * @property {string} variable
 */

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

// DOCS https://www.alfredapp.com/help/workflows/script-environment-variables/
const scriptEnvironment = [
	{title: "alfred_workflow_cache", subtitle: ""},
	{title: "alfred_workflow_data", subtitle: ""},
	{title: "alfred_workflow_name", subtitle: ""},
	{title: "alfred_preferences", subtitle: ""},
	{title: "alfred_version", subtitle: ""},
	"alfred_workflow_bundleid",
	"alfred_workflow_version",
	"alfred_workflow_uid",
];

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const workflowPath = $.getenv("workflow_path").trim();
	const alfredPrefsFront = $.getenv("focusedapp") === "com.runningwithcrayons.Alfred-Preferences";
	const shellCmd = `plutil -extract "userconfigurationconfig" json "${workflowPath}/info.plist" -o - || echo "{}"`;

	const workflowVars = JSON.parse(app.doShellScript(shellCmd)).map(
		(/** @type {WorkflowVariable} */ item) => {
			const { type, variable } = item;
			const output = alfredPrefsFront ? `{var:${variable}}` : variable;

			/** @type {AlfredItem} */
			const alfredItem = {
				title: variable,
				subtitle: type,
				arg: output,
				uid: variable, // only remember these
				match: camelCaseMatch(variable),
			};
			return alfredItem;
		},
	);

	const scriptEnvVars = scriptEnvironment.map((varname) => {
		const output = alfredPrefsFront ? `{var:${varname}}` : varname;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: varname,
			arg: output,
			icon: { path: "Alfred.icns" }, // differentiate script env vars from workflow vars
			match: camelCaseMatch(varname),
		};
		return alfredItem;
	});

	return JSON.stringify({ items: [...workflowVars, ...scriptEnvVars] });
}
