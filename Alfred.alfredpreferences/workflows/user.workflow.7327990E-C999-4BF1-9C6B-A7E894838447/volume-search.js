#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

const notToDisplay = [
	"Macintosh HD",
	"Samsung SSD 1TB",
	"GoogleDrive",
	"Recovery"
];

const singleVolumes = app.doShellScript("ls /Volumes")
	.split("\r")
	.filter(v => !notToDisplay.includes(v));

const volumeArray = [];
if (singleVolumes.length) {
	singleVolumes.forEach(element => {
		const diskSpace = app.doShellScript('df -h | grep "' + element + '" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," ').split(" ");
		const spaceInfo =
		"Total: " + diskSpace[0]
		+ "   Available: " + diskSpace[2]
		+ "   Used: " + diskSpace[1]
		+ " (" + diskSpace[3] + ")";

		volumeArray.push ({
			"title": element,
			"subtitle": spaceInfo,
			"arg": "/Volumes/"+ element
		});
	});
} else {
	volumeArray.push ({
		"title": "No mounted volume recognized.",
		"subtitle": "Press [Esc] to abort.",
		"arg": "no volume"
	});
}

volumeArray.push ({
	"title": "Disk Utility",
	"subtitle": "",
	"arg": "disk_utility",
	"icon": { "path" : "disk_utility.png" },
	"mods": {
		"cmd" : {
			"valid": false,
			"subtitle": ""
		}
	}
});

JSON.stringify({ "items": volumeArray });
