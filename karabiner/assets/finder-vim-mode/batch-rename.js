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

/** @param {{ item: { name: any; }; to: any; }} task */
function executeTask(task) {
	task.item.name = task.to;
}

//──────────────────────────────────────────────────────────────────────────────
// MAIN

const selection = [].slice.call(Application("Finder").selection());
const renamingFnReturn = prompt("How to modify the name?", "return name");
const renamingFn = new Function("name", renamingFnReturn);

try {
	const tasks = selection
		.map(function (/** @type {{ name: () => string; }} */ item) {
			const name = item.name();
			let target;
			try {
				target = renamingFn(name);
			} catch (error) {
				throw new Error(`Cannot rename "${name}": ${error}`);
			}
			if (!target) {
				throw new Error(`Cannot rename "${name}": expression returned empty result`);
			}
			return { item: item, from: name, to: target };
		})
		.filter(function (/** @type renameTask */ task) {
			return task.from !== task.to;
		});

	if (tasks.length === 0) throw new Error("No files to rename!");

	const message =
		"These files will be renamed:\n\n" +
		tasks
			.map(function (/** @type renameTask */ task) {
				return "- " + task.from + " => " + task.to;
			})
			.join("\n");

	if (confirm(message)) {
		tasks.forEach(executeTask);
	}
} catch (e) {
	alert("Error!", String(e));
}
