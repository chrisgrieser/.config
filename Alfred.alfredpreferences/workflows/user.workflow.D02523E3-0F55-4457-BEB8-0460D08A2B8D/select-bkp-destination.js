#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const volumes = app
	.doShellScript("ls /Volumes")
	.split("\r")
	.filter(v => {
		const toIgnore = ["TimeMachine", "Macintosh", "HDD", "SSD", "GoogleDrive"];
		return !toIgnore.includes(v);
	});

if (volumes.length === 0) {
	volumes.push({
		title: "No mounted volume recognized.",
		subtitle: "Press [Esc] to abort or select folder instead.",
		arg: "folder",
	});
} else {
	volumes.forEach(element => {
		const diskSpace = app
			.doShellScript('df -h | grep "' + element + '" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," ')
			.split(" ");
		const spaceInfo =
			"Total: " +
			diskSpace[0] +
			"   Available: " +
			diskSpace[2] +
			"   Used: " +
			diskSpace[1] +
			" (" +
			diskSpace[3] +
			")";
		volumes.push({
			title: element,
			subtitle: spaceInfo,
			arg: "/Volumes/" + element,
		});
	});
}
volumes.push({
	title: "Disk Utility",
	subtitle: "",
	arg: "disk_utility",
	icon: { path: "disk_utility.png" },
});

JSON.stringify({ items: volumes });
