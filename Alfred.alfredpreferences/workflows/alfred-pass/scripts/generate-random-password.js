#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	const pwCharacters = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	const pwLength =
		Number.parseInt(app.doShellScript("exec zsh -c 'echo \"$PASSWORD_STORE_GENERATED_LENGTH\"'")) ||
		25;

	let newPassword = "";
	for (let i = 0; i < pwLength; i++) {
		newPassword += pwCharacters.charAt(Math.floor(Math.random() * pwCharacters.length));
	}

	return newPassword;
}
