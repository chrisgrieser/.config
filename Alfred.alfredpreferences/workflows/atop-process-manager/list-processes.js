#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let rerunSecs = parseFloat($.getenv("rerun_s"));
	if (!rerunSecs) {
		return JSON.stringify({ items: [{ title: "⚠️ Invalid refresh value", valid: false }] });
	}
	if (rerunSecs <= 0) rerunSecs = 0.2;
	else if (rerunSecs > 5) rerunSecs = 5;

	const apps = app.doShellScript("ls /Applications/");
	const processes = app
		.doShellScript("ps rcAo 'pid=,%cpu=,command='")
		.split("\r")
		.map((/** @type {string} */ processInfo) => {
			const info = processInfo.trim().split(/\s+/);
			const pid = info[0];
			const cpu = info[1];
			let name = info[2];

			// app icons
			switch (name) {
				case "<defunct>":
					return {};
				case "Alfred":
					name += " 5";
					break;
				case "CleanShot":
					name += " X";
					break;
				case "neovide":
				case "espanso":
					name = name.charAt(0).toUpperCase() + name.slice(1); // capitalize
					break;
				case "wezterm-gui":
					name = "WezTerm";
					break;
			}
			const isApp = apps.includes(name);
			const icon = isApp ? { type: "fileicon", path: `/Applications/${name}.app` } : {};
			const subtitle = parseFloat(cpu) > 0.2 ? cpu : "";

			return {
				title: name,
				subtitle: subtitle,
				icon: icon,
				arg: pid,
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					alt: {
						valid: isApp,
						subtitle: isApp ? "⌥: Restart App" : "⌥: ⛔ Not an app",
						variables: { mode: "restart app" },
					},
				},
			};
		});

	return JSON.stringify({
		variables: { mode: "kill" },
		rerun: rerunSecs,
		items: processes,
	});
}
