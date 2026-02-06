#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	// 1. avoiding `Il` and `O0` due to them being too similar when entering password manually
	// 2. exclude special characters, since many services break with them :(
	const pwCharacters = "abcdefghijkmnopqrstuvwxyz123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
	const pwLength =
		Number.parseInt(app.doShellScript("exec zsh -c 'echo \"$PASSWORD_STORE_GENERATED_LENGTH\"'")) ||
		25;

	let newPassword = "";
	for (let i = 0; i < pwLength; i++) {
		newPassword += pwCharacters.charAt(Math.floor(Math.random() * pwCharacters.length));
	}

	return newPassword;
}
