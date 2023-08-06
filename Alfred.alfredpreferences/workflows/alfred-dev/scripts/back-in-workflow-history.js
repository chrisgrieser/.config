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

const historyFile = app.pathTo("home folder") + "/Library/Application Support/Alfred/history.json"
const navHistory = JSON.parse(readFile(historyFile)).preferences.workflows

const idOfLastWorkflow = navHistory[1]
Application("com.runningwithcrayons.Alfred").revealWorkflow(idOfLastWorkflow);
