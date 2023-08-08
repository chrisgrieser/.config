#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const selectableDns = [
		{
			title: "Google",
			subtitle: "8.8.8.8  &  8.8.4.4",
			arg: ["8.8.8.8", "8.8.4.4"],
			variables: { server_name: "Google" },
		},
		{
			title: "Cloudflare",
			subtitle: "1.1.1.1  &  1.0.0.1",
			arg: ["1.1.1.1", "1.0.0.1"],
			variables: { server_name: "Cloudflare" },
		},
	];

	// get current DNS
	const serviceName = app
		.doShellScript("networksetup -listallnetworkservices")
		.split("\r")[1] // get second line, since first is a header
		.replace("*", ""); // asterisk is used to mark disabled services
	const currentDns = app
		.doShellScript(`networksetup -getdnsservers "${serviceName}"`)
		.split("\r")[0]
	if (currentDns === "8.8.8.8") selectableDns[0].title = "✅ Google";
	else if (currentDns === "1.1.1.1") selectableDns[1].title = "✅ Cloudflare";

	return JSON.stringify({ items: selectableDns });
}
