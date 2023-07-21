#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

// https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
const historyFile = app.pathTo("home folder") + "/Library/Application Support/Alfred/history.json";
const navHistory = JSON.parse(readFile(historyFile)).preferences.workflows;
const currentWorkflowId = navHistory[0];

const prefsFile = app.pathTo("home folder") + "/Library/Application Support/Alfred/prefs.json";
const prefLocation = JSON.parse(readFile(prefsFile)).current;
const workflowFolderPath = `${prefLocation}/workflows/${currentWorkflowId}`;

workflowFolderPath // direct return
