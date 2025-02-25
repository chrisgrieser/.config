#!/bin/zsh --no-rcs

spacer='{
		"title": "",
		"subtitle": "System Settings → Accessibility",
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
		"title": "VoiceOver",
		"subtitle": "System Settings → Accessibility → VoiceOver",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?VoiceOver",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Hover Text",
		"subtitle": "System Settings → Accessibility → Hover Text",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?hoverText",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Zoom",
		"subtitle": "System Settings → Accessibility → Zoom",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Zoom",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Display",
		"subtitle": "System Settings → Accessibility → Display",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Display",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Spoken Content",
		"subtitle": "System Settings → Accessibility → Spoken Content",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?SpokenContent",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Descriptions",
		"subtitle": "System Settings → Accessibility → Descriptions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Descriptions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Hearing Devices",
		"subtitle": "System Settings → Accessibility → Hearing Devices",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Hearing",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Audio",
		"subtitle": "System Settings → Accessibility → Audio",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Audio",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "RTT",
		"subtitle": "System Settings → Accessibility → RTT",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?RTT",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Captions",
		"subtitle": "System Settings → Accessibility → Captions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Captions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Live Captions",
		"subtitle": "System Settings → Accessibility → Live Captions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?LiveCaptions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((1+${gap}*2))}; do echo $spacer; done)
	{
		"title": "Voice Control",
		"subtitle": "System Settings → Accessibility → Voice Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?VoiceControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Keyboard",
		"subtitle": "System Settings → Accessibility → Keyboard",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Keyboard",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Pointer Control",
		"subtitle": "System Settings → Accessibility → Pointer Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?PointerControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Switch Control",
		"subtitle": "System Settings → Accessibility → Switch Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?SwitchControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "Live Speech",
		"subtitle": "System Settings → Accessibility → Live Speech",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?LiveSpeech",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Personal Voice",
		"subtitle": "System Settings → Accessibility → Personal Voice",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?PersonalVoice",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Vocal Shortcuts",
		"subtitle": "System Settings → Accessibility → Vocal Shortcuts",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?vocalShortcuts",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	{
		"title": "Siri",
		"subtitle": "System Settings → Accessibility → Siri",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Siri",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	{
		"title": "Shortcut",
		"subtitle": "System Settings → Accessibility → Shortcut",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Shortcut",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "main.sh" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	$goBack
$itemClose
EOB