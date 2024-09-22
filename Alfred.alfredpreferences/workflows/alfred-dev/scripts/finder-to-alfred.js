#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const finderWinp = decodeURIComponent(Application("Finder").insertionLocation().url().slice(7));
	const [_, workflowUid] = finderWinp.match(/Alfred\.alfredpreferences\/workflows\/(.+)\//) || [];
	if (!workflowUid) return "Not in an Alfred directory."; // notification via Alfred

	// using JXA and URI for redundancy, as both are not 100 % reliable https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	Application("com.runningwithcrayons.Alfred").revealWorkflow(workflowUid);
	const uri = "alfredpreferences://navigateto/workflows>workflow>" + workflowUid;
	app.openLocation(uri);
}
