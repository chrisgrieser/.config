#!/bin/zsh --no-rcs

spacer='{
		"title": "",
		"subtitle": "System Settings → General",
		"valid": false,
		"icon": { "path": "" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},'
goBack='{
		"title": "Go Back",
		"subtitle": "System Settings",
		"arg": "main.sh",
		"icon": { "path": "images/Settings.png" }
	},'

gap=$((${gridCols}-6))
[[ "${submenu}" != "main.sh" ]] && itemOpen='{"items": [' && itemClose=']}' || goBack="${spacer}"

cat << EOB
$itemOpen
	{
		"title": "About",
		"subtitle": "System Settings → General → About",
		"arg": "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension",
		"icon": { "path": "images/About.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Software Update",
		"subtitle": "System Settings → General → Software Update",
		"arg": "x-apple.systempreferences:com.apple.Software-Update-Settings.extension",
		"icon": { "path": "images/Software Update.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Storage",
		"subtitle": "System Settings → General → Storage",
		"arg": "x-apple.systempreferences:com.apple.settings.Storage",
		"icon": { "path": "images/Storage.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((1+${gap}))}; do echo $spacer; done)
	{
		"title": "AppleCare & Warranty",
		"subtitle": "System Settings → General → AppleCare & Warranty",
		"arg": "x-apple.systempreferences:com.apple.Coverage-Settings.extension",
		"icon": { "path": "images/AppleCare & Warranty.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "AppleCare & and Warranty Coverage"
	},
	{
		"title": "Airdrop & Handoff",
		"subtitle": "System Settings → General → Airdrop & Handoff",
		"arg": "x-apple.systempreferences:com.apple.AirDrop-Handoff-Settings.extension",
		"icon": { "path": "images/Airdrop & Handoff.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Airdrop & and Handoff"
	},
	{
		"title": "Autofill & Passwords",
		"subtitle": "System Settings → General → Autofill & Passwords",
		"arg": "x-apple.systempreferences:com.apple.Passwords-Settings.extension",
		"icon": { "path": "images/Autofill & Passwords.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Autofill & and Passwords"
	},
	{
		"title": "Date & Time",
		"subtitle": "System Settings → General → Date & Time",
		"arg": "x-apple.systempreferences:com.apple.Date-Time-Settings.extension",
		"icon": { "path": "images/Date & Time.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Date & and Time"
	},
	{
		"title": "Language & Region",
		"subtitle": "System Settings → General → Language & Region",
		"arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension",
		"icon": { "path": "images/Language & Region.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Language & and Region"
	},
	{
		"title": "Login Items & Extensions",
		"subtitle": "System Settings → General → Login Items & Extensions",
		"arg": "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
		"icon": { "path": "images/Login Items & Extensions.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Login Items & and Extensions"
	},
	{
		"title": "Sharing",
		"subtitle": "System Settings → General → Storage",
		"arg": "x-apple.systempreferences:com.apple.Sharing-Settings.extension",
		"icon": { "path": "images/Storage.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Sharing SSH SFTP SMB Samba AFP"
	},
	{
		"title": "Startup Disk",
		"subtitle": "System Settings → General → Startup Disk",
		"arg": "x-apple.systempreferences:com.apple.Startup-Disk-Settings.extension",
		"icon": { "path": "images/Startup Disk.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Time Machine",
		"subtitle": "System Settings → General → Time Machine",
		"arg": "x-apple.systempreferences:com.apple.Time-Machine-Settings.extension",
		"icon": { "path": "images/Time Machine.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Time Machine Backup"
	},
	$([[ ${gridCols} != 7 ]] && for i in {1..$((5+${gap}*2 < ${gridCols} ? 5:1))}; do echo $spacer; done)
	{
		"title": "Device Management",
		"subtitle": "System Settings → General → Device Management",
		"arg": "x-apple.systempreferences:com.apple.Profiles-Settings.extension",
		"icon": { "path": "images/Device Management.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Device Management Profiles"
	},
	{
		"title": "Transfer or Reset",
		"subtitle": "System Settings → General → Transfer or Reset",
		"arg": "x-apple.systempreferences:com.apple.Transfer-Reset-Settings.extension",
		"icon": { "path": "images/Transfer or Reset.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	$goBack
$itemClose
EOB