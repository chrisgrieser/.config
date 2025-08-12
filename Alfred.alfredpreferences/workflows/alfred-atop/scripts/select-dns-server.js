#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const selectableDns = [
		{ name: "Google", addresses: ["8.8.8.8", "8.8.4.4"] },
		{ name: "Cloudflare", addresses: ["1.1.1.1", "1.0.0.1"] },
		{ name: "AliDNS", addresses: ["223.5.5.5", "223.6.6.6"] },
		{ name: "Mullvad", addresses: ["194.242.2.4", "194.242.2.3"] },
		{ name: "DNS0", addresses: ["193.110.81.0", "185.253.5.0"] },
		{ name: "Quad9", addresses: ["9.9.9.9", "149.112.112.112"] },
		{ name: "AdGuard", addresses: ["94.140.14.14", "94.140.15.15"] },
	];

	const dnsAlfredItems = selectableDns.map((dns) => {
		return {
			title: dns.name,
			subtitle: dns.addresses.join("  ▪  "),
			arg: dns.addresses,
			variables: { serverName: dns.name }, // for Alfred notification
		};
	});
	dnsAlfredItems.push({
		title: "Clear DNS setting",
		subtitle: "will use the DNS provided by the router",
		arg: ["", ""],
		variables: { serverName: "DNS provided by router" },
	});

	//───────────────────────────────────────────────────────────────────────────

	// find first enabled service
	const serviceName = app
		.doShellScript("networksetup -listallnetworkservices")
		.split("\r")
		.find((line) => !line.includes("*")); // asterisk is used to mark disabled services
	const currentDns = app
		.doShellScript(`networksetup -getdnsservers "${serviceName}"`)
		.split("\r")[0];
	for (const dns of dnsAlfredItems) {
		if (dns.arg[0] === currentDns) dns.title += " ✅";
	}

	return JSON.stringify({ items: dnsAlfredItems });
}
