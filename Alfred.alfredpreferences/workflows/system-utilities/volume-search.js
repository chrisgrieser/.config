#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

const notToDisplay = [
	"Macintosh HD",
	"Samsung SSD 1TB",
	"GoogleDrive",
	"Recovery"
];

//──────────────────────────────────────────────────────────────────────────────

const volumes = app.doShellScript("ls /Volumes/")
	.split("\r")
	.map((/** @type {string} */ vol) => {
		if (!notToDisplay.includes(vol)) return {};
		const diskSpace = app.doShellScript(`df -h | grep "${vol}" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," `).split(" ");
		const spaceInfo =
		"Total: " + diskSpace[0]
		+ "   Available: " + diskSpace[2]
		+ "   Used: " + diskSpace[1]
		+ " (" + diskSpace[3] + ")";

		return{
			"title": "📂 " + vol,
			"subtitle": spaceInfo,
			"arg": "/Volumes/"+ vol
		};
	});

if (volumes.length === 0) {
	volumes.push ({
		"title": "No mounted volume recognized.",
		"subtitle": "Press [Esc] to abort.",
		"arg": "no volume"
	});
}


JSON.stringify({
	"rerun":
	"items": volumeArray,
});
