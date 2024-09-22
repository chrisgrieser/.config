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
		return '⚠️ "Alfred Workflow Devtools" cannot reload itself.';
	}

	// delete cache
	const bundleId = app.doShellScript(
		`plutil -extract "bundleid" raw -o - "${workflowPath}/info.plist"`,
	);
	const cacheFolder =
		app.pathTo("home folder") +
		"/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/" +
		bundleId;
	app.doShellScript(`rm -rf '${cacheFolder}/'*`);

	// reload
	Application("com.runningwithcrayons.Alfred").reloadWorkflow(workflowUid);

	// alfred notification
	return bundleId + ": reloaded & deleted cache.";
}
