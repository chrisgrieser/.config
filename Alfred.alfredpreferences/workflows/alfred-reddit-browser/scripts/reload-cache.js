#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const workflowId = $.getenv("alfred_workflow_bundleid");
	const alfredApp = Application("com.runningwithcrayons.Alfred");
	alfredApp.reloadWorkflow(workflowId);
}
