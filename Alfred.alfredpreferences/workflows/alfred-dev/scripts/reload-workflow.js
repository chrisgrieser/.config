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

	// GUARD
	if (!workflowUid) return "⚠️ Error reloading workflow: " + workflowPath;
	if (workflowUid === $.getenv("alfred_workflow_uid")) {
		return "⚠️ Alfred Workflow Devtools cannot reload itself.";
	}

	// CAVEAT cannot delete the cache of a non-active workflow, since we can only
	// get the uid

	// reload
	Application("com.runningwithcrayons.Alfred").reloadWorkflow(workflowUid);

	// alfred notification
	return "Reloaded & deleted cache: " + workflowUid; 
}
