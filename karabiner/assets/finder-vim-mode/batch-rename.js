#!/usr/bin/env osascript -l JavaScript
//──────────────────────────────────────────────────────────────────────────────
// INFO source: https://gist.github.com/dtinth/93e230152a771dcb1ec5
//──────────────────────────────────────────────────────────────────────────────

const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @typedef {Object} renameTask
 * @property {string} from
 * @property {string} to
 */

//──────────────────────────────────────────────────────────────────────────────
// Recipes from: https://github.com/dtinth/JXA-Cookbook/wiki/User-Interactions

/**
 * @param {string} text
 * @param {string} defaultAnswer
 */
function prompt(text, defaultAnswer) {
	const options = { defaultAnswer: defaultAnswer || "" };
	try {
		return app.displayDialog(text, options).textReturned;
	} catch (_) {
		return null;
	}
}

/**
 * @param {string} text
 * @param {string} informationalText
 */
function alert(text, informationalText) {
	const options = {};
	if (informationalText) options.message = informationalText;
	app.displayAlert(text, options);
}

/** @param {string} text */
function confirm(text) {
	try {
		app.displayDialog(text);
		return true;
	} catch (_) {
		return false;
	}
}

//──────────────────────────────────────────────────────────────────────────────
// MAIN

const userResponse = prompt("Enter regex. \nsearch/replace", "/");
const selectedFiles = [].slice.call(Application("Finder").selection());

try {
	const tasks = selectedFiles
		.map(function (/** @type {{ name: () => string; }} */ item) {
			const name = item.name();
			const [search, replace] = userResponse.split("/");
			const searchRegExp = new RegExp(search, "g");
			if (!searchRegExp) throw new Error(`${search} is not a valid regex.`);
			const renameTo = name.replace(searchRegExp, replace);
			if (!renameTo) throw new Error(`"${name}": expression has empty result`);
			return { item: item, from: name, to: renameTo };
		})
		.filter((/** @type {renameTask} */ task) => task.from !== task.to);

	if (tasks.length === 0) throw new Error("No files to rename.");

	const message =
		"These files will be renamed:\n\n" +
		tasks.map((/** @type {renameTask} */ task) => "- " + task.from + " => " + task.to).join("\n");

	if (confirm(message)) {
		tasks.forEach((/** @type {{ item: { name: any; }; to: any; }} */ task) => {
			task.item.name = task.to;
		});
	}
} catch (e) {
	alert("Error!", String(e));
}
