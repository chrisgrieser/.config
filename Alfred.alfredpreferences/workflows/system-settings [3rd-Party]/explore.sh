#!/bin/zsh --no-rcs

gap=$((${gridCols}-6))

function settings {
    spacer='{
		"title": "",
		"subtitle": "System Settings",
		"valid": false
	},'
    vpn='{
		"title": "VPN",
		"subtitle": "System Settings → VPN",
		"arg": "x-apple.systempreferences:com.apple.NetworkExtensionSettingsUI.NESettingsUIExtension*vpn",
		"icon": { "path": "images/VPN.png" }
	},'

    [[ $(bioutil -r) == *"Biometrics"* ]] && loginPassword="Touch ID & Password" || loginPassword="Login Password"
    [[ $(sysctl -n machdep.cpu.brand_string) == *"Apple"* ]] && siri="Apple Intelligence & Siri" || siri="Siri"
    [[ $(pmset -g ps) == *"InternalBattery"* ]] && battery="Battery" || battery="Energy"
    if [[ $(scutil --nc list | wc -l) -gt 1 ]]; then
        showVPN="${vpn}"
    else
        spacerVPN="${spacer}"
        matchVPN="VPN"
    fi

    cat << EOB
	{
		"title": "Apple ID",
		"subtitle": "System Settings → Apple ID",
		"arg": "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings*AppleIDSettings",
		"icon": { "path": "images/Apple ID.png" }
	},
	{
		"title": "Family",
		"subtitle": "System Settings → Family",
		"arg": "x-apple.systempreferences:com.apple.Family-Settings.extension*Family",
		"icon": { "path": "images/Family.png" }
	},
	{
		"title": "Media & Purchases",
		"subtitle": "System Settings → Apple ID → Media & Purchases",
		"arg": "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings*AppleIDSettings?com.apple.AppleMediaServicesUI.SpyglassPurchases",
		"icon": { "path": "images/Media & Purchases.png" },
		"match": "Media & and Purchases Subscriptions"
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	{
		"title": "Wi-Fi",
		"subtitle": "System Settings → Wi-Fi",
		"arg": "x-apple.systempreferences:com.apple.wifi-settings-extension",
		"icon": { "path": "images/Wi-Fi.png" },
		"match": "Wi-Fi wifi"
	},
	{
		"title": "Bluetooth",
		"subtitle": "System Settings → Bluetooth",
		"arg": "x-apple.systempreferences:com.apple.BluetoothSettings",
		"icon": { "path": "images/Bluetooth.png" }
	},
	{
		"title": "Network",
		"subtitle": "System Settings → Network",
		"arg": "x-apple.systempreferences:com.apple.Network-Settings.extension",
		"icon": { "path": "images/Network.png" },
		"match": "Network Firewall DNS Locations ${matchVPN}"
	},
	${showVPN}
	{
		"title": "${battery}",
		"subtitle": "System Settings → ${battery}",
		"arg": "x-apple.systempreferences:com.apple.Battery-Settings.extension*BatteryPreferences",
		"icon": { "path": "images/${battery}.png" },
		"match": "Battery Energy Saver"
	},
	${spacerVPN}
	$(for i in {1..$((1+${gap}))}; do echo $spacer; done)
	{
		"title": "General",
		"subtitle": "System Settings → General",
		"arg": "general",
		"icon": { "path": "images/General.png" },
		"mods": { "cmd": { "subtitle": "⌘↩ Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.systempreferences.GeneralSettings" } }
	},
	{
		"title": "Accessibility",
		"subtitle": "System Settings → Accessibility",
		"arg": "accessibility",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "cmd": { "subtitle": "⌘↩ Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension" } }
	},
	{
		"title": "Appearance",
		"subtitle": "System Settings → Appearance",
		"arg": "x-apple.systempreferences:com.apple.Appearance-Settings.extension",
		"icon": { "path": "images/Appearance.png" },
		"match": "Appearance Dark Light"
	},
	{
		"title": "Menu Bar",
		"subtitle": "System Settings → Menu Bar",
		"arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension*menubar",
		"icon": { "path": "images/Control Center.png" },
		"match": "Control Center Centre Menu bar Menubar"
	},
	{
		"title": "${siri}",
		"subtitle": "System Settings → ${siri}",
		"arg": "x-apple.systempreferences:com.apple.Siri-Settings.extension",
		"icon": { "path": "images/${siri}.png" },
		"match": "Apple Intelligence & and Siri"
	},
	{
		"title": "Desktop & Dock",
		"subtitle": "System Settings → Desktop & Dock",
		"arg": "x-apple.systempreferences:com.apple.Desktop-Settings.extension",
		"icon": { "path": "images/Desktop & Dock.png" },
		"match": "Desktop & and Dock Stage Manager Mission Control Widgets Default Web Browser Spaces"
	},
	{
		"title": "Displays",
		"subtitle": "System Settings → Displays",
		"arg": "x-apple.systempreferences:com.apple.Displays-Settings.extension",
		"icon": { "path": "images/Displays.png" }
	},
	{
		"title": "Spotlight",
		"subtitle": "System Settings → Spotlight",
		"arg": "x-apple.systempreferences:com.apple.Spotlight-Settings.extension",
		"icon": { "path": "images/Spotlight.png" }
	},
	{
		"title": "Wallpaper",
		"subtitle": "System Settings → Wallpaper",
		"arg": "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension",
		"icon": { "path": "images/Wallpaper.png" }
	},
	$(for i in {1..$((3+${gap}*2))}; do echo $spacer; done)
	{
		"title": "Notifications",
		"subtitle": "System Settings → Notifications",
		"arg": "x-apple.systempreferences:com.apple.Notifications-Settings.extension",
		"icon": { "path": "images/Notifications.png" }
	},
	{
		"title": "Sound",
		"subtitle": "System Settings → Sound",
		"arg": "x-apple.systempreferences:com.apple.Sound-Settings.extension",
		"icon": { "path": "images/Sound.png" }
	},
	{
		"title": "Focus",
		"subtitle": "System Settings → Focus",
		"arg": "x-apple.systempreferences:com.apple.Focus-Settings.extension",
		"icon": { "path": "images/Focus.png" }
	},
	{
		"title": "Screen Time",
		"subtitle": "System Settings → Screen Time",
		"arg": "x-apple.systempreferences:com.apple.Screen-Time-Settings.extension",
		"icon": { "path": "images/Screen Time.png" }
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "Lock Screen",
		"subtitle": "System Settings → Lock Screen",
		"arg": "x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension",
		"icon": { "path": "images/Lock Screen.png" }
	},
	{
		"title": "Privacy & Security",
		"subtitle": "System Settings → Privacy & Security",
		"arg": "privacySecurity",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "cmd": { "subtitle": "⌘↩ Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension" } },
		"match": "Privacy & and Security"
	},
	{
		"title": "${loginPassword}",
		"subtitle": "System Settings → ${loginPassword}",
		"arg": "x-apple.systempreferences:com.apple.Touch-ID-Settings.extension*TouchIDPasswordPrefs",
		"icon": { "path": "images/${loginPassword}.png" },
		"match": "Touch ID & and Login Password"
	},
	{
		"title": "Users & Groups",
		"subtitle": "System Settings → Users & Groups",
		"arg": "x-apple.systempreferences:com.apple.Users-Groups-Settings.extension",
		"icon": { "path": "images/Users & Groups.png" },
		"match": "Users & and Groups"
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "Internet Accounts",
		"subtitle": "System Settings → Internet Accounts",
		"arg": "x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension",
		"icon": { "path": "images/Internet Accounts.png" }
	},
	{
		"title": "Game Center",
		"subtitle": "System Settings → Game Center",
		"arg": "x-apple.systempreferences:com.apple.Game-Center-Settings.extension",
		"icon": { "path": "images/Game Center.png" },
		"match": "Game Center Centre"
	},
	{
		"title": "iCloud",
		"subtitle": "System Settings → iCloud",
		"arg": "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings:icloud",
		"icon": { "path": "images/iCloud.png" }
	},
	{
		"title": "Wallet & Apple Pay",
		"subtitle": "System Settings → Wallet & Apple Pay",
		"arg": "x-apple.systempreferences:com.apple.WalletSettingsExtension",
		"icon": { "path": "images/Wallet & Apple Pay.png" },
		"match": "Wallet & and Apple Pay Payment"
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "Keyboard",
		"subtitle": "System Settings → Keyboard",
		"arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
		"icon": { "path": "images/Keyboard.png" },
		"match": "Keyboard Shortcuts Dictation"
	},
	{
		"title": "Mouse",
		"subtitle": "System Settings → Mouse",
		"arg": "x-apple.systempreferences:com.apple.Mouse-Settings.extension",
		"icon": { "path": "images/Mouse.png" }
	},
	{
		"title": "Trackpad",
		"subtitle": "System Settings → Trackpad",
		"arg": "x-apple.systempreferences:com.apple.Trackpad-Settings.extension",
		"icon": { "path": "images/Trackpad.png" }
	},
	{
		"title": "Game Controller",
		"subtitle": "System Settings → Game Controller",
		"arg": "x-apple.systempreferences:com.apple.Game-Controller-Settings.extension",
		"icon": { "path": "images/Game Controller.png" }
	},
	{
		"title": "Printers & Scanners",
		"subtitle": "System Settings → Printers & Scanners",
		"arg": "x-apple.systempreferences:com.apple.Print-Scan-Settings.extension",
		"icon": { "path": "images/Printers & Scanners.png" },
		"match": "Printers & and Scanners"
	},
	$(for i in {1..$((1+${gap}))}; do echo $spacer; done)
EOB
}
function general {
    spacer='{
		"title": "",
		"subtitle": "System Settings → General",
		"valid": false,
		"mods": { "shift": { "subtitle": "System Settings" } }
	},'
    goBack='{
		"title": "Go Back",
		"subtitle": "System Settings",
		"icon": { "path": "images/Settings.png" }
	},'

    [[ -z "${submenu}" ]] && goBack="${spacer}"

    cat << EOB
	{
		"title": "About",
		"subtitle": "System Settings → General → About",
		"arg": "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension",
		"icon": { "path": "images/About.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Software Update",
		"subtitle": "System Settings → General → Software Update",
		"arg": "x-apple.systempreferences:com.apple.Software-Update-Settings.extension",
		"icon": { "path": "images/Software Update.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Storage",
		"subtitle": "System Settings → General → Storage",
		"arg": "x-apple.systempreferences:com.apple.settings.Storage",
		"icon": { "path": "images/Storage.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((1+${gap}))}; do echo $spacer; done)
	{
		"title": "AppleCare & Warranty",
		"subtitle": "System Settings → General → AppleCare & Warranty",
		"arg": "x-apple.systempreferences:com.apple.Coverage-Settings.extension",
		"icon": { "path": "images/AppleCare & Warranty.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "AppleCare & and Warranty Coverage"
	},
	{
		"title": "Airdrop & Handoff",
		"subtitle": "System Settings → General → Airdrop & Handoff",
		"arg": "x-apple.systempreferences:com.apple.AirDrop-Handoff-Settings.extension",
		"icon": { "path": "images/Airdrop & Handoff.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Airdrop & and Handoff"
	},
	{
		"title": "Autofill & Passwords",
		"subtitle": "System Settings → General → Autofill & Passwords",
		"arg": "x-apple.systempreferences:com.apple.Passwords-Settings.extension",
		"icon": { "path": "images/Autofill & Passwords.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Autofill & and Passwords"
	},
	{
		"title": "Date & Time",
		"subtitle": "System Settings → General → Date & Time",
		"arg": "x-apple.systempreferences:com.apple.Date-Time-Settings.extension",
		"icon": { "path": "images/Date & Time.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Date & and Time"
	},
	{
		"title": "Language & Region",
		"subtitle": "System Settings → General → Language & Region",
		"arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension",
		"icon": { "path": "images/Language & Region.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Language & and Region"
	},
	{
		"title": "Login Items & Extensions",
		"subtitle": "System Settings → General → Login Items & Extensions",
		"arg": "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
		"icon": { "path": "images/Login Items & Extensions.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Login Items & and Extensions"
	},
	{
		"title": "Sharing",
		"subtitle": "System Settings → General → Storage",
		"arg": "x-apple.systempreferences:com.apple.Sharing-Settings.extension",
		"icon": { "path": "images/Storage.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Sharing SSH SFTP SMB Samba AFP"
	},
	{
		"title": "Startup Disk",
		"subtitle": "System Settings → General → Startup Disk",
		"arg": "x-apple.systempreferences:com.apple.Startup-Disk-Settings.extension",
		"icon": { "path": "images/Startup Disk.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Time Machine",
		"subtitle": "System Settings → General → Time Machine",
		"arg": "x-apple.systempreferences:com.apple.Time-Machine-Settings.extension",
		"icon": { "path": "images/Time Machine.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Time Machine Backup"
	},
	$([[ ${gridCols} != 7 ]] && for i in {1..$((5+${gap}*2 < ${gridCols} ? 5:1))}; do echo $spacer; done)
	{
		"title": "Device Management",
		"subtitle": "System Settings → General → Device Management",
		"arg": "x-apple.systempreferences:com.apple.Profiles-Settings.extension",
		"icon": { "path": "images/Device Management.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Device Management Profiles"
	},
	{
		"title": "Transfer or Reset",
		"subtitle": "System Settings → General → Transfer or Reset",
		"arg": "x-apple.systempreferences:com.apple.Transfer-Reset-Settings.extension",
		"icon": { "path": "images/Transfer or Reset.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	${goBack}
EOB
}
function accessibility {
    spacer='{
		"title": "",
		"subtitle": "System Settings → Accessibility",
		"valid": false,
		"mods": { "shift": { "subtitle": "System Settings" } }
	},'
    goBack='{
		"title": "Go Back",
		"subtitle": "System Settings",
		"icon": { "path": "images/Settings.png" }
	},'

    [[ -z "${submenu}" ]] && goBack="${spacer}"

    cat << EOB
	{
		"title": "VoiceOver",
		"subtitle": "System Settings → Accessibility → VoiceOver",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?VoiceOver",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Hover Text",
		"subtitle": "System Settings → Accessibility → Hover Text",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?hoverText",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Zoom",
		"subtitle": "System Settings → Accessibility → Zoom",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Zoom",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Display",
		"subtitle": "System Settings → Accessibility → Display",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Display",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Spoken Content",
		"subtitle": "System Settings → Accessibility → Spoken Content",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?SpokenContent",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Descriptions",
		"subtitle": "System Settings → Accessibility → Descriptions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Descriptions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Hearing Devices",
		"subtitle": "System Settings → Accessibility → Hearing Devices",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Hearing",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Audio",
		"subtitle": "System Settings → Accessibility → Audio",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Audio",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "RTT",
		"subtitle": "System Settings → Accessibility → RTT",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?RTT",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Captions",
		"subtitle": "System Settings → Accessibility → Captions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Captions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Live Captions",
		"subtitle": "System Settings → Accessibility → Live Captions",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?LiveCaptions",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((1+${gap}*2))}; do echo $spacer; done)
	{
		"title": "Voice Control",
		"subtitle": "System Settings → Accessibility → Voice Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?VoiceControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Keyboard",
		"subtitle": "System Settings → Accessibility → Keyboard",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Keyboard",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Pointer Control",
		"subtitle": "System Settings → Accessibility → Pointer Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?PointerControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Switch Control",
		"subtitle": "System Settings → Accessibility → Switch Control",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?SwitchControl",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "Live Speech",
		"subtitle": "System Settings → Accessibility → Live Speech",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?LiveSpeech",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Personal Voice",
		"subtitle": "System Settings → Accessibility → Personal Voice",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?PersonalVoice",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Vocal Shortcuts",
		"subtitle": "System Settings → Accessibility → Vocal Shortcuts",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?vocalShortcuts",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	{
		"title": "Siri",
		"subtitle": "System Settings → Accessibility → Siri",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Siri",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Shortcut",
		"subtitle": "System Settings → Accessibility → Shortcut",
		"arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Shortcut",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	${goBack}
EOB
}
function privacySecurity {
    # Apple Intelligence Report, Local Network currently have no URL

    spacer='{
		"title": "",
		"subtitle": "System Settings → Privacy & Security",
		"valid": false,
		"mods": { "shift": { "subtitle": "System Settings" } }
	},'
    goBack='{
		"title": "Go Back",
		"subtitle": "System Settings",
		"icon": { "path": "images/Settings.png" }
	},'

    [[ -z "${submenu}" ]] && goBack="${spacer}"

    cat << EOB
	{
		"title": "Location Services",
		"subtitle": "System Settings → Privacy & Security → Location Services",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_LocationServices",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((5+${gap}))}; do echo $spacer; done)
	{
		"title": "Calendars",
		"subtitle": "System Settings → Privacy & Security → Calendars",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Calendars",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Contacts",
		"subtitle": "System Settings → Privacy & Security → Contacts",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Contacts",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Files and Folders",
		"subtitle": "System Settings → Privacy & Security → Files and Folders",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_FilesAndFolders",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Full Disk Access",
		"subtitle": "System Settings → Privacy & Security → Full Disk Access",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "HomeKit",
		"subtitle": "System Settings → Privacy & Security → HomeKit",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_HomeKit",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Media & Apple Music",
		"subtitle": "System Settings → Privacy & Security → Media & Apple Music",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Media",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Media & and Apple Music"
	},
	{
		"title": "Passkeys Access for Web Browsers",
		"subtitle": "System Settings → Privacy & Security → Passkeys Access for Web Browsers",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_PasskeyAccess",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Photos",
		"subtitle": "System Settings → Privacy & Security → Photos",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Photos",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Reminders",
		"subtitle": "System Settings → Privacy & Security → Reminders",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Reminders",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((3+${gap}*2))}; do echo $spacer; done)
	{
		"title": "Accessibility",
		"subtitle": "System Settings → Privacy & Security → Accessibility",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "App Management",
		"subtitle": "System Settings → Privacy & Security → App Management",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AppBundles",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Automation",
		"subtitle": "System Settings → Privacy & Security → Automation",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Automation",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Bluetooth",
		"subtitle": "System Settings → Privacy & Security → Bluetooth",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Bluetooth",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Camera",
		"subtitle": "System Settings → Privacy & Security → Camera",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Camera",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Developer Tools",
		"subtitle": "System Settings → Privacy & Security → Developer Tools",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_DevTools",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Focus",
		"subtitle": "System Settings → Privacy & Security → Focus",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Focus",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Input Monitoring",
		"subtitle": "System Settings → Privacy & Security → Input Monitoring",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ListenEvent",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Local Network",
		"subtitle": "System Settings → Privacy & Security → Local Network",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Microphone",
		"subtitle": "System Settings → Privacy & Security → Microphone",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Microphone",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Motion & Fitness",
		"subtitle": "System Settings → Privacy & Security → Motion & Fitness",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Motion",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Motion & and Fitness"
	},
	{
		"title": "Remote Desktop",
		"subtitle": "System Settings → Privacy & Security → Remote Desktop",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_RemoteDesktop",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Screen & System Audio Recording",
		"subtitle": "System Settings → Privacy & Security → Screen & System Audio Recording",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Screen & an System Audio Recording"
	},
	{
		"title": "Speech Recognition",
		"subtitle": "System Settings → Privacy & Security → Speech Recognition",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_SpeechRecognition",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$([[ ${gridCols} != 7 ]] && for i in {1..$((4+${gap}*3 < ${gridCols} ? 4:2))}; do echo $spacer; done)
	{
		"title": "Sensitive Content Warning",
		"subtitle": "System Settings → Privacy & Security → Sensitive Content Warning",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_NudityDetection",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Analytics & Improvements",
		"subtitle": "System Settings → Privacy & Security → Analytics & Improvements",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Analytics",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } },
		"match": "Analytics & and Improvements"
	},
	{
		"title": "Apple Advertising",
		"subtitle": "System Settings → Privacy & Security → Apple Advertising",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Advertising",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Apple Intelligence Report",
		"subtitle": "System Settings → Privacy & Security → Apple Intelligence Report",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Security",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((2+${gap}))}; do echo $spacer; done)
	{
		"title": "FileVault",
		"subtitle": "System Settings → Privacy & Security → FileVault",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?FileVault",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	{
		"title": "Lockdown Mode",
		"subtitle": "System Settings → Privacy & Security → Lockdown Mode",
		"arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?LockdownMode",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "shift": { "subtitle": "System Settings", "arg": "" } }
	},
	$(for i in {1..$((3+${gap}))}; do echo $spacer; done)
	${goBack}
EOB
}

echo '{"items": ['
[[ -z "${submenu}" ]] && settings
[[ (-z "${submenu}" && "${showGeneral}" -eq 1) || "${submenu}" == "general" ]] && general
[[ (-z "${submenu}" && "${showAccessibility}" -eq 1) || "${submenu}" == "accessibility" ]] && accessibility
[[ (-z "${submenu}" && "${showPrivacySecurity}" -eq 1) || "${submenu}" == "privacySecurity" ]] && privacySecurity
echo ']}'
