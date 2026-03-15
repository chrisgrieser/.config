#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const dnsChoices = $.getenv("dns_choices")
		.split("\n")
		.map((line) => {
			const [name, address1, address2] = line.trim().split(/\s*,\s*/);
			if (!name || !address1 || !address2) return {};
			return {
				title: name,
				subtitle: address1 + "  ▪  " + address2,
				arg: [address1, address2],
				variables: { serverName: name }, // for Alfred notification
			};
		});

	// transform list of DNS servers into Alfred items
	dnsChoices.push({
		title: "❌ Clear DNS setting",
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
	for (const dns of dnsChoices) {
		if (dns.arg?.[0] === currentDns) dns.title += " ✅";
	}

	return JSON.stringify({ items: dnsChoices });
}
