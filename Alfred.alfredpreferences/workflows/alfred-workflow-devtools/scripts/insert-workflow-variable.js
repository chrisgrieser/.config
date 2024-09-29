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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const workflowPath = argv[0].trim();
	const shellCmd = `plutil -extract "userconfigurationconfig" json "${workflowPath}/info.plist" -o - || echo "{}"`;
	const workflowVars = JSON.parse(app.doShellScript(shellCmd));

	const vars = workflowVars.map((/** @type {WorkflowVariable} */ item) => {
		const { type, variable } = item;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: variable,
			subtitle: type,
			arg: variable,
			uid: variable,
			match: camelCaseMatch(variable),
		};
		return alfredItem;
	});

	return JSON.stringify({ items: vars });
}
