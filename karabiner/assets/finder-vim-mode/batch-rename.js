#!/usr/bin/env osascript -l JavaScript
//──────────────────────────────────────────────────────────────────────────────
// INFO source: https://gist.github.com/dtinth/93e230152a771dcb1ec5
//──────────────────────────────────────────────────────────────────────────────

ObjC.import("stdlib");
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

const selectedFiles = [].slice.call(Application("Finder").selection());

try {
	const tasks = selectedFiles
		.map(function (/** @type {{ name: () => string; }} */ item) {
			const name = item.name();
			let renameTo;
			try {
				const userResponse = prompt("How to modify the name? \n search/replace", "/");
				const [search, replace] = userResponse.split("/");
				const searchRegExp = new RegExp(search, "gm");
				renameTo = name.replace(searchRegExp, replace);
			} catch (error) {
				throw new Error(`"${name}": ${error}`);
			}
			if (!renameTo) {
				throw new Error(`"${name}": expression has empty result`);
			}
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
