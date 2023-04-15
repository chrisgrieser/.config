#!/usr/bin/env osascript -l JavaScript
function finderFrontWindow() {
	const posixPath = finderWindow => $.NSURL.alloc.initWithString(finderWindow.target.url()).fileSystemRepresentation;
	return posixPath(Application("Finder").finderWindows[0]);
}

function run() {
	const winPath = finderFrontWindow();
	if (!winPath.includes("Alfred.alfredpreferences/workflows")) return "Not in Alfred directory.";

	const workflowId = winPath.match(/Alfred\.alfredpreferences\/workflows\/([^/]+)/)[1];

	Application("com.runningwithcrayons.Alfred").revealWorkflow(workflowId);
	return;
}
