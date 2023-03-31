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
	.doShellScript("echo $PATH | tr ':' '\n' | xargs -I {} find {} -maxdepth 1 -type f -perm '++x'")
	.split("\r")
	.map(path => path.replaceAll("//", "/"));

binaries = [...new Set(binaries)] // only unique
	.sort((a, b) => {
		if (a.includes("homebrew") && b.includes("homebrew"))
		return b - a;
	})
	.map(binary => {
		const cmd = binary.split("/").pop();
		let type = "";
		if (binary.includes("homebrew")) type = "homebrew";
		else if (binary.includes("bin")) type = "builtin";
		return {
			title: cmd,
			subtitle: type,
			match: alfredMatcher(cmd),
			arg: baseURL + cmd,
			uid: cmd,
		};
	});

JSON.stringify({ items: binaries });
