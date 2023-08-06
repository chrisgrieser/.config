#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {

	// https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	const historyFile = app.pathTo("home folder") + "/Library/Application Support/Alfred/history.json";
	const navHistory = JSON.parse(readFile(historyFile)).preferences.workflows;
	const currentWorkflowId = navHistory[0];

	const prefLocation = $.getenv("alfred_preferences");
	const workflowFolderPath = `${prefLocation}/workflows/${currentWorkflowId}`;

	return workflowFolderPath;
}
