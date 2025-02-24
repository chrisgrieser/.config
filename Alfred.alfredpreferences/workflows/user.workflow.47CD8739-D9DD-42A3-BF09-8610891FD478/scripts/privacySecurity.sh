#!/bin/zsh --no-rcs

# Apple Intelligence Report, Local Network currently have no URL

spacer='{
		"title": "",
		"subtitle": "System Settings → Privacy & Security",
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
		"title": "Location Services",
		"subtitle": "System Settings → Privacy & Security → Location Services",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_LocationServices",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((5+${gap}))}; do echo $spacer; done)
	{
		"title": "Calendars",
		"subtitle": "System Settings → Privacy & Security → Calendars",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Calendars",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Contacts",
		"subtitle": "System Settings → Privacy & Security → Contacts",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Contacts",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Files and Folders",
		"subtitle": "System Settings → Privacy & Security → Files and Folders",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_FilesAndFolders",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Full Disk Access",
		"subtitle": "System Settings → Privacy & Security → Full Disk Access",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "HomeKit",
		"subtitle": "System Settings → Privacy & Security → HomeKit",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_HomeKit",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Media & Apple Music",
		"subtitle": "System Settings → Privacy & Security → Media & Apple Music",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Media",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Media & and Apple Music"
	},
	{
		"title": "Passkeys Access for Web Browsers",
		"subtitle": "System Settings → Privacy & Security → Passkeys Access for Web Browsers",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_PasskeyAccess",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Photos",
		"subtitle": "System Settings → Privacy & Security → Photos",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Photos",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Reminders",
		"subtitle": "System Settings → Privacy & Security → Reminders",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Reminders",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((3+${gap}*2))}; do echo $spacer; done)
	{
		"title": "Accessibility",
		"subtitle": "System Settings → Privacy & Security → Accessibility",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "App Management",
		"subtitle": "System Settings → Privacy & Security → App Management",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AppBundles",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Automation",
		"subtitle": "System Settings → Privacy & Security → Automation",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Automation",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Bluetooth",
		"subtitle": "System Settings → Privacy & Security → Bluetooth",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Bluetooth",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Camera",
		"subtitle": "System Settings → Privacy & Security → Camera",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Camera",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Developer Tools",
		"subtitle": "System Settings → Privacy & Security → Developer Tools",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_DevTools",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Focus",
		"subtitle": "System Settings → Privacy & Security → Focus",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Focus",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Input Monitoring",
		"subtitle": "System Settings → Privacy & Security → Input Monitoring",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ListenEvent",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Local Network",
		"subtitle": "System Settings → Privacy & Security → Local Network",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Microphone",
		"subtitle": "System Settings → Privacy & Security → Microphone",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Microphone",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Motion & Fitness",
		"subtitle": "System Settings → Privacy & Security → Motion & Fitness",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Motion",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Motion & and Fitness"
	},
	{
		"title": "Remote Desktop",
		"subtitle": "System Settings → Privacy & Security → Remote Desktop",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_RemoteDesktop",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Screen & System Audio Recording",
		"subtitle": "System Settings → Privacy & Security → Screen & System Audio Recording",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Screen & an System Audio Recording"
	},
	{
		"title": "Speech Recognition",
		"subtitle": "System Settings → Privacy & Security → Speech Recognition",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_SpeechRecognition",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$([[ ${gridCols} != 7 ]] && for i in {1..$((4+${gap}*3 < ${gridCols} ? 4:2))}; do echo $spacer; done)
	{
		"title": "Sensitive Content Warning",
		"subtitle": "System Settings → Privacy & Security → Sensitive Content Warning",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_NudityDetection",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Analytics & Improvements",
		"subtitle": "System Settings → Privacy & Security → Analytics & Improvements",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Analytics",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } },
		"match": "Analytics & and Improvements"
	},
	{
		"title": "Apple Advertising",
		"subtitle": "System Settings → Privacy & Security → Apple Advertising",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Advertising",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Apple Intelligence Report",
		"subtitle": "System Settings → Privacy & Security → Apple Intelligence Report",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Security",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "FileVault",
		"subtitle": "System Settings → Privacy & Security → FileVault",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?FileVault",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Lockdown Mode",
		"subtitle": "System Settings → Privacy & Security → Lockdown Mode",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?LockdownMode",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	$goBack
$itemClose
EOB