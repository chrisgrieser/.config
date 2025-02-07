#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
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
		{
			title: "AliDNS",
			subtitle: "223.5.5.5  &  223.6.6.6",
			arg: ["223.5.5.5", "223.6.6.6"],
			variables: { server_name: "AliDNS" },
		},
		{
			title: "Mullvad",
			subtitle: "194.242.2.4 & 194.242.2.3",
			arg: ["194.242.2.4", "194.242.2.3"],
			variables: { server_name: "Mullvad" },
		},
		{
			title: "DNS0",
			subtitle: "193.110.81.0 & 185.253.5.0",
			arg: ["193.110.81.0", "185.253.5.0"],
			variables: { server_name: "DNS0" },
		},
		{
			title: "Quad9",
			subtitle: "9.9.9.9 & 149.112.112.112",
			arg: ["9.9.9.9", "149.112.112.112"],
			variables: { server_name: "Quad9" },
		},
		{
			title: "AdGuard",
			subtitle: "94.140.14.14 & 94.140.15.15",
			arg: ["94.140.14.14", "94.140.15.15"],
			variables: { server_name: "AdGuard" },
		},
	];

	// get current DNS
	const serviceName = app
		.doShellScript("networksetup -listallnetworkservices")
		.split("\r")[1] // get second line, since first is a header
		.replace("*", ""); // asterisk is used to mark disabled services
	const currentDns = app
		.doShellScript(`networksetup -getdnsservers "${serviceName}"`)
		.split("\r")[0];
	if (currentDns === "8.8.8.8") selectableDns[0].title = "✅ Google";
	else if (currentDns === "1.1.1.1") selectableDns[1].title = "✅ Cloudflare";
	else if (currentDns === "223.5.5.5") selectableDns[2].title = "✅ AliDNS";
	else if (currentDns === "194.242.2.4") selectableDns[3].title = "✅ Mullvad";
	else if (currentDns === "193.110.81.0") selectableDns[4].title = "✅ DNS0";
	else if (currentDns === "9.9.9.9") selectableDns[5].title = "✅ quad9";
	else if (currentDns === "94.140.14.14") selectableDns[6].title = "✅ AdGuard";

	return JSON.stringify({ items: selectableDns });
}
