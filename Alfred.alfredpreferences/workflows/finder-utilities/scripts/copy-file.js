#!/usr/bin/env osascript -l JavaScript
// https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/User-Interaction-with-Files-and-Folders#copy-a-file-to-pasteboard
ObjC.import("AppKit");

/** @param {string} path */
function copyPathToClipboard(path) {
	const pasteboard = $.NSPasteboard.generalPasteboard;
	pasteboard.clearContents;
	const success = pasteboard.setPropertyListForType($([path]), $.NSFilenamesPboardType);
	return success;
}

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const path = argv[0];
	const success = copyPathToClipboard(path);
	if (success) return "success"; // triggers Alfred notification
}
