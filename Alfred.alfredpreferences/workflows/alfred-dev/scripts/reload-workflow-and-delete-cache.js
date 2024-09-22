#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const workflowPath = argv[0].trim();
	const workflowUid = workflowPath.split("/").pop();
	if (!workflowUid) return "Error reloading workflow " + workflowPath;
	if (workflowUid === $.getenv("alfred_workflow_uid")) return "This workflow cannot reload itself";

	const alfredApp = Application("com.runningwithcrayons.Alfred");
	alfredApp.reloadWorkflow(workflowUid);
	return "Reloaded: " + workflowUid; // pass back for notification
}
