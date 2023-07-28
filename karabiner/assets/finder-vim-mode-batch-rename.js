#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const Finder = Application("Finder");
const selection = [].slice.call(Finder.selection());
const code = prompt("How to modify the name?", "return name");
const fn = new Function("name", code);

try {
	const tasks = selection
		.map(function (/** @type {{ name: () => any; }} */ item) {
			const name = item.name();
			let target
			try {
				target = fn(name);
			} catch (e) {
				throw new Error('Cannot rename "' + name + '": ' + e);
			}
			if (!target) {
				throw new Error('Cannot rename "' + name + '": expression returned empty result');
			}
			return { item: item, from: name, to: target };
		})
		.filter(function (/** @type {{ from: any; to: any; }} */ task) {
			return task.from !== task.to;
		});

	if (tasks.length === 0) throw new Error("No files to rename!");

	const message =
		"These files will be renamed:\n\n" +
		tasks
			.map(function (task) {
				return "- " + task.from + " => " + task.to;
			})
			.join("\n");

	if (confirm(message)) {
		tasks.forEach(executeTask);
	}
} catch (e) {
	alert("Error!", String(e));
}

// Recipes from: https://github.com/dtinth/JXA-Cookbook/wiki/User-Interactions

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
