#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const selectableDns = [
		{ title: "Google", addresses: ["8.8.8.8", "8.8.4.4"] },
		{ title: "Cloudflare", ips: ["1.1.1.1", "1.0.0.1"] },
		{ title: "AliDNS", ips: ["223.5.5.5", "223.6.6.6"] },
		{ title: "Mullvad", ips: ["194.242.2.4", "194.242.2.3"] },
		{ title: "DNS0", ips: ["193.110.81.0", "185.253.5.0"] },
		{ title: "Quad9", ips: ["9.9.9.9", "149.112.112.112"] },
		{ title: "AdGuard", ips: ["94.140.14.14", "94.140.15.15"] },
	];

	/** @type {AlfredItem[]} */
	const dnsAlfredItems = selectableDns.map((dns) => {
		return {
			title: dns.title,
			subtitle: dns.subtitle,
			arg: dns.arg,
			valid: true,
		};
	});

	for (const dns of selectableDns) {
		dns.subtitle = dns
	}

	selectableDns.push({
		title: "Clear DNS setting",
		subtitle: "Will use the DNS provided by the router.",
		arg: ["", ""],
	});

	// get current DNS
	const serviceName = app
		.doShellScript("networksetup -listallnetworkservices")
		.split("\r")
		.find((line) => !line.includes("*")); // asterisk is used to mark disabled services
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
	else selectableDns[7].title = "✅ Other";

	return JSON.stringify({ items: selectableDns });
}
