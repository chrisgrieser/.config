#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

const dnsChoices = [
	{ name: "Google", addresses: ["8.8.8.8", "8.8.4.4"] },
	{ name: "Cloudflare", addresses: ["1.1.1.1", "1.0.0.1"] },
	{ name: "AliDNS", addresses: ["223.5.5.5", "223.6.6.6"] },
	{ name: "Mullvad", addresses: ["194.242.2.4", "194.242.2.3"] },
	{ name: "DNS0", addresses: ["193.110.81.0", "185.253.5.0"] },
	{ name: "Quad9", addresses: ["9.9.9.9", "149.112.112.112"] },
	{ name: "AdGuard", addresses: ["94.140.14.14", "94.140.15.15"] },
];

//------------------------------------------------------------------------------

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// transform list of DNS servers into Alfred items
	const dnsAlfredItems = dnsChoices.map((dns) => ({
		title: dns.name,
		subtitle: dns.addresses.join("  ▪  "),
		arg: dns.addresses,
		variables: { serverName: dns.name }, // for Alfred notification
	}));
	dnsAlfredItems.push({
		title: "Clear DNS setting",
		subtitle: "will use the DNS provided by the router",
		arg: ["", ""],
		variables: { serverName: "DNS provided by router" },
	});

	// add icon to currently used DNS
	const serviceName = app
		.doShellScript("networksetup -listallnetworkservices")
		.split("\r")
		.find((line) => !line.includes("*")); // skip "asterisk (*) denotes disabled services"
	const currentDns = app
		.doShellScript(`networksetup -getdnsservers "${serviceName}"`)
		.split("\r")[0];
	for (const dns of dnsAlfredItems) {
		if (dns.arg[0] === currentDns) dns.title += " ✅";
	}

	return JSON.stringify({ items: dnsAlfredItems });
}
