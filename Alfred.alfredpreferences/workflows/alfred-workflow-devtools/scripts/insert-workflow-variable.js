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
	{ name: "alfred_workflow_cache" },
	{ name: "alfred_workflow_data" },
	{ name: "alfred_workflow_name" },
	{ name: "alfred_theme" },
	{ name: "alfred_theme_background" },
	// biome-ignore format: not needed
	{ name: "alfred_theme_subtext", desc: "The subtext mode the user has selected in the Appearance preferences." },
	{ name: "alfred_workflow_description" },
	{ name: "alfred_preferences", desc: "The location of Alfred.alfredpreferences" },
	// biome-ignore format: not needed
	{ name: "alfred_preferences_localhash", desc: "Local (Mac-specific) preferences under [Alfred.alfredpreferences]/preferences/local/[localhash]" },
	{ name: "alfred_version" },
	{ name: "alfred_workflow_bundleid" },
	{ name: "alfred_workflow_uid", desc: "i.e. the name of the workflow folder" },
	{ name: "alfred_workflow_version" },
	{ name: "alfred_workflow_keyword", desc: "The keyword the script filter was triggered with." },
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
			const { type, variable, config } = item;
			const output = alfredPrefsFront ? `{var:${variable}}` : variable;

			const subtitle = [
				type,
				config.required ? "[required]" : "",
				config.default ? `default: ${config.default}` : "",
			]
				.filter(Boolean)
				.join("    ");

			/** @type {AlfredItem} */
			const alfredItem = {
				title: variable,
				subtitle: subtitle,
				arg: output,
				uid: variable, // only remember these
				match: camelCaseMatch(variable),
			};
			return alfredItem;
		},
	);

	const scriptEnvVars = scriptEnvironment.map((varr) => {
		const output = alfredPrefsFront ? `{const:${varr.name}}` : varr.name;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: varr.name,
			subtitle: varr.desc || "",
			arg: output,
			icon: { path: "Alfred.icns" }, // differentiate script env vars from workflow vars
			match: camelCaseMatch(varr.name),
		};
		return alfredItem;
	});

	return JSON.stringify({ items: [...workflowVars, ...scriptEnvVars] });
}
