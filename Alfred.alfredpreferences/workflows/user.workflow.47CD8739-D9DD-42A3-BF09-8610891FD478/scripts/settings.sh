#!/bin/zsh --no-rcs

spacer='{
		"title": "",
		"subtitle": "System Settings",
		"valid": false,
		"icon": { "path": "" }
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
    spacerVPN=""
    matchVPN=""
else
    showVPN=""
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
	$spacer
	$spacer
	$spacer
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
		"match": "Network Firewall DNS ${matchVPN}"
	},
	$showVPN
	{
		"title": "Battery",
		"subtitle": "System Settings → Battery",
		"arg": "x-apple.systempreferences:com.apple.Battery-Settings.extension*BatteryPreferences",
		"icon": { "path": "images/Battery.png" },
		"match": "Battery Energy Saver"
	},
	$spacerVPN
	$spacer
	{
		"title": "General",
		"subtitle": "System Settings → General",
		"arg": "general.sh",
		"icon": { "path": "images/General.png" },
		"mods": { "cmd": { "subtitle": "Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.systempreferences.GeneralSettings" } }
	},
	{
		"title": "Accessibility",
		"subtitle": "System Settings → Accessibility",
		"arg": "accessibility.sh",
		"icon": { "path": "images/Accessibility.png" },
		"mods": { "cmd": { "subtitle": "Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.Accessibility-Settings.extension" } }
	},
	{
		"title": "Appearance",
		"subtitle": "System Settings → Appearance",
		"arg": "x-apple.systempreferences:com.apple.Appearance-Settings.extension",
		"icon": { "path": "images/Appearance.png" },
		"match": "Appearance Dark Light"
	},
	{
		"title": "Control Center",
		"subtitle": "System Settings → Control Center",
		"arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension",
		"icon": { "path": "images/Control Center.png" },
		"match": "Control Center Centre Menu bar Menubar"
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
		"title": "Screen Saver",
		"subtitle": "System Settings → Screen Saver",
		"arg": "x-apple.systempreferences:com.apple.ScreenSaver-Settings.extension",
		"icon": { "path": "images/Screen Saver.png" }
	},
	{
		"title": "${siri}",
		"subtitle": "System Settings → ${siri}",
		"arg": "x-apple.systempreferences:com.apple.Siri-Settings.extension",
		"icon": { "path": "images/${siri}.png" },
		"match": "Apple Intelligence & and Siri"
	},
	{
		"title": "Wallpaper",
		"subtitle": "System Settings → Wallpaper",
		"arg": "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension",
		"icon": { "path": "images/Wallpaper.png" }
	},
	$spacer
	$spacer
	$spacer
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
	$spacer
	$spacer
	{
		"title": "Lock Screen",
		"subtitle": "System Settings → Lock Screen",
		"arg": "x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension",
		"icon": { "path": "images/Lock Screen.png" }
	},
	{
		"title": "Privacy & Security",
		"subtitle": "System Settings → Privacy & Security",
		"arg": "privacySecurity.sh",
		"icon": { "path": "images/Privacy & Security.png" },
		"mods": { "cmd": { "subtitle": "Open Pane in System Settings", "arg": "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension" } },
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
	$spacer
	$spacer
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
		"title": "Spotlight",
		"subtitle": "System Settings → Spotlight",
		"arg": "x-apple.systempreferences:com.apple.Spotlight-Settings.extension",
		"icon": { "path": "images/Spotlight.png" }
	},
	{
		"title": "Wallet & Apple Pay",
		"subtitle": "System Settings → Wallet & Apple Pay",
		"arg": "x-apple.systempreferences:com.apple.WalletSettingsExtension",
		"icon": { "path": "images/Wallet & Apple Pay.png" },
		"match": "Wallet & and Apple Pay Payment"
	},
	$spacer
	{
		"title": "Keyboard",
		"subtitle": "System Settings → Keyboard",
		"arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
		"icon": { "path": "images/Keyboard.png" },
		"match": "Keyboard Dictation"
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
	$spacer
EOB