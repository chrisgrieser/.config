#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

const baseURL = "https://man.cx/";

let binaries = app
	.doShellScript("echo $PATH | tr ':' '\n' | xargs -I {} find {} -maxdepth 1 -type f -or -type l -perm '++x'")
	.split("\r")
	.map(path => path.replaceAll("//", "/"));

binaries = [...new Set(binaries)] // only unique
	.sort((a, b) => { // sort homebrew installs first
		if (a.includes("brew") && !b.includes("brew")) return -1;
		if (!a.includes("brew") && b.includes("brew")) return 1;
		return 0;
	})
	.map(binary => {
		const cmd = binary.split("/").pop();
		let icon = "";
		if (binary.includes("brew")) icon += " 🍺";
		return {
			title: cmd + icon,
			match: alfredMatcher(cmd),
			arg: baseURL + cmd,
			uid: cmd,
		};
	});

JSON.stringify({ items: binaries });
