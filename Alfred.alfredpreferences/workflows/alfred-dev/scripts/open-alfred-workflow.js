#!/usr/bin/env osascript -l JavaScript

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const finder = Application("Finder");
	const finderWinPath = decodeURIComponent(finder.insertionLocation().url().slice(7));

	const workflowId = finderWinPath.match(/Alfred\.alfredpreferences\/workflows\/([^/]+)/)?.[1];
	if (!workflowId) return "Not in Alfred directory.";

	Application("com.runningwithcrayons.Alfred").revealWorkflow(workflowId);
	return;
}
