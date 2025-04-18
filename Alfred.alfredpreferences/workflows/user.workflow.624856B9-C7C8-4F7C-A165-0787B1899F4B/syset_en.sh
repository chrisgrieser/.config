#!/bin/zsh --no-rcs

cat <<EOF
{ "items":
  [
    {
      "uid": "Accessibility General",
      "title": "Accessibility General",
      "subtitle": "Open the 'Accessibility General' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess",
      "autocomplete": "Accessibility General",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Audio",
      "title": "Accessibility → Audio",
      "subtitle": "Open the 'Accessibility → Audio' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Audio",
      "autocomplete": "Accessibility → Audio",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },    
    {
      "uid": "Accessibility → Hearing Devices",
      "title": "Accessibility → Hearing Devices",
      "subtitle": "Open the 'Accessibility → Hearing Devices' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Hearing",
      "autocomplete": "Accessibility → Hearing Devices",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Captions",
      "title": "Accessibility → Captions",
      "subtitle": "Open the 'Accessibility → Captions' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Captioning",
      "autocomplete": "Accessibility → Captions",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Audio Descriptions",
      "title": "Accessibility → Audio Descriptions",
      "subtitle": "Open the 'Accessibility → Audio Descriptions' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Media_Descriptions",
      "autocomplete": "Accessibility → Audio Descriptions",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Display",
      "title": "Accessibility → Display",
      "subtitle": "Open the 'Accessibility → Display' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display",
      "autocomplete": "Accessibility → Display",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Keyboard",
      "title": "Accessibility → Keyboard",
      "subtitle": "Open the 'Accessibility → Keyboard' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Keyboard",
      "autocomplete": "Accessibility → Keyboard",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Pointer Control",
      "title": "Accessibility → Pointer Control",
      "match": "accessibility mouse trackpad pointer control",
      "subtitle": "Open the 'Accessibility → Pointer Control' pane (if a mouse has been connected)",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?PointerControl",
      "autocomplete": "Accessibility → Pointer Control",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibilty → Switch Control",
      "title": "Accessibilty → Switch Control",
      "subtitle": "Open the 'Accessibilty → Switch Control' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Switch",
      "autocomplete": "Accessibilty → Switch Control",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → VoiceOver",
      "title": "Accessibility → VoiceOver",
      "subtitle": "Open the 'Accessibility → VoiceOver' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_VoiceOver",
      "autocomplete": "Accessibility → VoiceOver",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Zoom",
      "title": "Accessibility → Zoom",
      "subtitle": "Open the 'Accessibility → Zoom' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Zoom",
      "autocomplete": "Accessibility → Zoom",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "AirDrop & Handoff",
      "title": "AirDrop & Handoff",
      "subtitle": "Open the 'AirDrop & Handoff' pane",
      "arg": "x-apple.systempreferences:com.apple.AirDrop-Handoff-Settings.extension",
      "autocomplete": "AirDrop & Handoff",
      "icon": {
        "path": "./Images/AirDrop.png"
      }
    },
    {
      "uid": "Appearance",
      "title": "Appearance",
      "subtitle": "Open the 'Appearance' pane",
      "arg": "x-apple.systempreferences:com.apple.Appearance-Settings.extension",
      "autocomplete": "Appearance",
      "icon": {
        "path": "./Images/Appearance.png"
      }
    },
    {
      "uid": "Apple Account",
      "title": "Apple Account",
      "match": "apple id account",      
      "subtitle": "Open the 'Apple Account' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane",
      "autocomplete": "Apple Account",
      "icon": {
        "path": "./Images/AppleID.png"
      }
    },
    {
      "uid": "Apple Intelligence & Siri",
      "title": "Apple Intelligence & Siri",
      "subtitle": "Open the 'Apple Intelligence & Siri' pane",
      "arg": "x-apple.systempreferences:com.apple.Siri-Settings.extension*siri-sae",
      "autocomplete": "Apple Intelligence & Siri",
      "icon": {
        "path": "./Images/AppleIntelligence.png"
      }
    },
    {
      "uid": "Autofill & Passwords",
      "title": "Autofill & Passwords",
      "subtitle": "Open the 'Autofill & Passwords' pane",
      "arg": "x-apple.systempreferences:com.apple.Passwords-Settings.extension",
      "autocomplete": "Autofill & Passwords",
      "icon": {
        "path": "./Images/Passwords.png"
      }
    },
    {
      "uid": "Battery",
      "title": "Battery",
      "match": "energy power battery",
      "subtitle": "Open the 'Battery' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.battery",
      "autocomplete": "Battery",
      "icon": {
        "path": "./Images/Battery.png"
      }
    },
    {
      "uid": "Bluetooth",
      "title": "Bluetooth",
      "subtitle": "Open the 'Bluetooth' pane",
      "arg": "x-apple.systempreferences:com.apple.BluetoothSettings",
      "autocomplete": "Bluetooth",
      "icon": {
        "path": "./Images/Bluetooth.png"
      }
    },
    {
      "uid": "Control Centre",
      "title": "Control Centre",
      "subtitle": "Open the 'Control Centre' pane",
      "arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension",
      "autocomplete": "Control Centre",
      "icon": {
        "path": "./Images/ControlCentre.png"
      }
    },
    {
      "uid": "Control Centre → Menu Bar",
      "title": "Control Centre → Menu Bar",
      "subtitle": "Open the 'Control Centre → Menu Bar' pane",
      "arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension?MenuBar",
      "autocomplete": "Control Centre → Menu Bar",
      "icon": {
        "path": "./Images/ControlCentre.png"
      }
    },    
    {
      "uid": "Desktop & Dock",
      "title": "Desktop & Dock",
      "subtitle": "Open the 'Desktop & Dock' pane",
      "arg": "x-apple.systempreferences:com.apple.Desktop-Settings.extension",
      "autocomplete": "Desktop & Dock",
      "icon": {
        "path": "./Images/DesktopDock.png"
      }
    },
    {
      "uid": "Displays",
      "title": "Displays",
      "subtitle": "Open the 'Displays' pane",
      "arg": "x-apple.systempreferences:com.apple.Displays-Settings.extension",
      "autocomplete": "Displays",
      "icon": {
        "path": "./Images/Displays.png"
      }
    },
    {
      "uid": "Family",
      "title": "Family",
      "subtitle": "Open the 'Family' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.FamilySharingPrefPane",
      "autocomplete": "Family Sharing",
      "icon": {
        "path": "./Images/Family.png"
      }
    },
    {
      "uid": "Focus",
      "title": "Focus",
      "subtitle": "Open the 'Focus' pane",
      "arg": "x-apple.systempreferences:com.apple.Focus-Settings.extension",
      "autocomplete": "Focus",
      "icon": {
        "path": "./Images/Focus.png"
      }
    },
    {
      "uid": "Game Centre",
      "title": "Game Centre",
      "subtitle": "Open the 'Game Centre' pane",
      "arg": "x-apple.systempreferences:com.apple.Game-Center-Settings.extension",
      "autocomplete": "Game Centre",
      "icon": {
        "path": "./Images/GameCentre.png"
      }
    },
    {
      "uid": "Game Controllers",
      "title": "Game Controllers",
      "subtitle": "Open the 'Game Controllers' pane (if a game controller has been connected)",
      "arg": "x-apple.systempreferences:com.apple.Game-Controller-Settings.extension",
      "autocomplete": "Game Controllers",
      "icon": {
        "path": "./Images/GameControllers.png"
      }
    },
    {
      "uid": "General",
      "title": "General",
      "subtitle": "Open the 'General' pane",
      "arg": "x-apple.systempreferences:com.apple.systempreferences.General",
      "autocomplete": "General",
      "icon": {
        "path": "./Images/General.png"
      }
    },
     {
      "uid": "General → About",
      "title": "General → About",
      "subtitle": "Open the 'General → About' pane",
      "arg": "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension",
      "autocomplete": "General → About",
      "icon": {
        "path": "./Images/About.png"
      }
    },
    {
      "uid": "General → AppleCare & Warranty",
      "title": "General → AppleCare & Warranty",
      "subtitle": "Open the 'General → AppleCare & Warranty' pane",
      "arg": "x-apple.systempreferences:com.apple.Coverage-Settings.extension",
      "autocomplete": "General → AppleCare & Warranty",
      "icon": {
        "path": "./Images/Coverage.png"
      }
    },
     {
      "uid": "General → Date & Time",
      "title": "General → Date & Time",
      "subtitle": "Open the 'General → Date & Time' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.datetime",
      "autocomplete": "General → Date & Time",
      "icon": {
        "path": "./Images/DateTime.png"
      }
    },
    {
      "uid": "General → Device Management",
      "title": "General → Device Management",
      "match": "general device managament profiles",
      "subtitle": "Open the 'General → Device Management' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.configurationprofiles",
      "autocomplete": "General → Device Management",
      "icon": {
        "path": "./Images/Profiles.png"
      }
    },
    {
      "uid": "General → Languages & Region",
      "title": "General → Languages & Region",
      "subtitle": "Open the 'General → Languages & Region' pane",
      "arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension",
      "autocomplete": "General → Languages & Region",
      "icon": {
        "path": "./Images/LanguagesRegion.png"
      }
    },
     {
      "uid": "General → Languages & Region → Translation Languages",
      "title": "General → Languages & Region → Translation Languages",
      "subtitle": "Open the 'General → Languages & Region → Translation Languages' pane",
      "arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension?translation",
      "autocomplete": "General → Languages & Region → Translation Languages",
      "icon": {
        "path": "./Images/LanguagesRegion.png"
      }
    },
    {
      "uid": "General → Login Items & Extensions",
      "title": "General → Login Items & Extensions",
      "subtitle": "Open the 'General → Login Items & Extensions' pane",
      "arg": "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
      "autocomplete": "General → Login Items & Extensions",
      "icon": {
        "path": "./Images/LoginItems.png"
      }
    },
    {
      "uid": "General → Sharing",
      "title": "General → Sharing",
      "subtitle": "Open the 'General → Sharing' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing",
      "autocomplete": "General → Sharing",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Internet Sharing",
      "title": "General → Sharing → Internet Sharing",
      "subtitle": "Open the 'General → Sharing → Internet Sharing' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Internet",
      "autocomplete": "General → Sharing → Internet Sharing",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Printer Sharing",
      "title": "General → Sharing → Printer Sharing",
      "subtitle": "Open the 'General → Sharing → Printer Sharing' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_PrinterSharing",
      "autocomplete": "General → Sharing → Printer Sharing",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Application Scripting",
      "title": "General → Sharing → Remote Application Scripting",
      "subtitle": "Open the 'General → Sharing → Remote Application Scripting' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteAppleEvent",
      "autocomplete": "General → Sharing → Remote Application Scripting",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Management",
      "title": "General → Sharing → Remote Management",
      "match": "ard general sharing remote management",
      "subtitle": "Open the 'General → Sharing → Remote Management' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_ARDService",
      "autocomplete": "General → Sharing → Remote Management",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Login",
      "title": "General → Sharing → Remote Login",
      "match": "general sharing remote login ssh",
      "subtitle": "Open the 'General → Sharing → Remote Login' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteLogin",
      "autocomplete": "General → Sharing → Remote Login",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },    
	{
      "uid": "General → Sharing → Screen Sharing",
      "title": "General → Sharing → Screen Sharing",
      "match": "vnc general sharing screen",
      "subtitle": "Open the 'General → Sharing → Screen Sharing' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_ScreenSharing",
      "autocomplete": "General → Sharing → Screen Sharing",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },    
	{
      "uid": "General → Software Update",
      "title": "General → Software Update",
      "subtitle": "Open the 'General → Software Update' panel",
      "arg": "x-apple.systempreferences:com.apple.Software-Update-Settings.extension",
      "autocomplete": "General → Software Update",
      "icon": {
        "path": "./Images/SoftwareUpdate.png"
      }
    },
    {
      "uid": "General → Startup Disk",
      "title": "General → Startup Disk",
      "subtitle": "Open the 'General → Startup Disk' pane",
      "arg": "x-apple.systempreferences:com.apple.Startup-Disk-Settings.extension",
      "autocomplete": "General → Startup Disk",
      "icon": {
        "path": "./Images/StartupDisk.png"
      }
    },
    {
      "uid": "General → Storage",
      "title": "General → Storage",
      "subtitle": "Open the 'General → Storage' pane",
      "arg": "x-apple.systempreferences:com.apple.settings.Storage",
      "autocomplete": "General → Storage",
      "icon": {
        "path": "./Images/Storage.png"
      }
    },
    {
      "uid": "General → Time Machine",
      "title": "General → Time Machine",
      "match": "backup general time machine",      
      "subtitle": "Open the 'General → Time Machine' pane",
      "arg": "x-apple.systempreferences:com.apple.Time-Machine-Settings.extension",
      "autocomplete": "General → Time Machine",
      "icon": {
        "path": "./Images/TimeMachine.png"
      }
    },
    {
      "uid": "General → Transfer or Reset",
      "title": "General → Transfer or Reset",
      "subtitle": "Open the 'General → Transfer or Reset' pane",
      "arg": "x-apple.systempreferences:com.apple.Transfer-Reset-Settings.extension",
      "autocomplete": "General → Transfer or Reset",
      "icon": {
        "path": "./Images/TransferReset.png"
      }
    },    
    {
      "uid": "iCloud",
      "title": "iCloud",
      "subtitle": "Open the 'iCloud' pane",
      "arg": "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings:icloud",
      "autocomplete": "iCloud",
      "icon": {
        "path": "./Images/iCloud.png"
      }
    },
    {
      "uid": "Internet Accounts",
      "title": "Internet Accounts",
      "subtitle": "Open the 'Internet Accounts' pane",
      "arg": "x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension",
      "autocomplete": "Internet Accounts",
      "icon": {
        "path": "./Images/InternetAccounts.png"
      }
    },
    {
      "uid": "Keyboard",
      "title": "Keyboard",
      "subtitle": "Open the 'Keyboard' pane",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
      "autocomplete": "Keyboard",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Function Keys",
      "title": "Keyboard → Function Keys",
      "subtitle": "Open the 'Keyboard → Function Keys' pane",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?FunctionKeys",
      "autocomplete": "Keyboard → Function Keys",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Modifier Keys",
      "title": "Keyboard → Modifier Keys",
      "subtitle": "Open the 'Keyboard → Modifier Keys' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts",
      "autocomplete": "Keyboard → Modifier Keys",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Text Replacements",
      "title": "Keyboard → Text Replacements",
      "subtitle": "Open the 'Keyboard → Text Replacements' pane",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?TextReplacements",
      "autocomplete": "Keyboard → Text Replacements",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
        {
      "uid": "Lock Screen",
      "title": "Lock Screen",
      "subtitle": "Open the 'Lock Screen' pane",
      "arg": "x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension",
      "autocomplete": "Lock Screen",
      "icon": {
        "path": "./Images/LockScreen.png"
      }
    },
    {
      "uid": "Mouse",
      "title": "Mouse",
      "subtitle": "Open the 'Mouse' pane (if a mouse has been connected)",
      "arg": "x-apple.systempreferences:com.apple.Mouse-Settings.extension",
      "autocomplete": "Mouse",
      "icon": {
        "path": "./Images/Mouse.png"
      }
    },    
    {
      "uid": "Network",
      "title": "Network",
      "subtitle": "Open the 'Network' pane",
      "arg": "x-apple.systempreferences:com.apple.Network-Settings.extension",
      "autocomplete": "Network",
      "icon": {
        "path": "./Images/Network.png"
      }
    },
    {
      "uid": "Notifications",
      "title": "Notifications",
      "subtitle": "Open the 'Notifications' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.notifications",
      "autocomplete": "Notifications",
      "icon": {
        "path": "./Images/Notifications.png"
      }
    },
    {
      "uid": "Printers & Scanners",
      "title": "Printers & Scanners",
      "subtitle": "Open the 'Printers & Scanners' pane",
      "arg": "x-apple.systempreferences:com.apple.Print-Scan-Settings.extension",
      "autocomplete": "Printers & Scanners",
      "icon": {
        "path": "./Images/PrintersScanners.png"
      }
    },
    {
      "uid": "Privacy & Security General",
      "title": "Privacy & Security General",
      "subtitle": "Open the 'Privacy & Security General' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security",
      "autocomplete": "Privacy & Security General",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Accessibility",
      "title": "Privacy & Security → Accessibility",
      "subtitle": "Open the 'Privacy & Security → Accessibility' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
      "autocomplete": "Privacy & Security → Accessibility",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Advertising",
      "title": "Privacy & Security → Advertising",
      "subtitle": "Open the 'Privacy & Security → Advertising' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Advertising",
      "autocomplete": "Privacy & Security → Advertising",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
     {
      "uid": "Privacy & Security → App Management",
      "title": "Privacy & Security → App Management",
      "subtitle": "Open the 'Privacy & Security → App Management' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles",
      "autocomplete": "Privacy & Security → App Management",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Automation",
      "title": "Privacy & Security → Automation",
      "subtitle": "Open the 'Privacy & Security → Automation' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation",
      "autocomplete": "Privacy & Security → Automation",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Bluetooth",
      "title": "Privacy & Security → Bluetooth",
      "subtitle": "Open the 'Privacy & Security → Bluetooth' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth",
      "autocomplete": "Privacy & Security → Bluetooth",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Calendars",
      "title": "Privacy & Security → Calendars",
      "subtitle": "Open the 'Privacy & Security → Calendars' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars",
      "autocomplete": "Privacy & Security → Calendars",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Camera",
      "title": "Privacy & Security → Camera",
      "subtitle": "Open the 'Privacy & Security → Camera' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera",
      "autocomplete": "Privacy & Security → Camera",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Contacts",
      "title": "Privacy & Security → Contacts",
      "subtitle": "Open the 'Privacy & Security → Contacts' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts",
      "autocomplete": "Privacy & Security → Contacts",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Files and Folders",
      "title": "Privacy & Security → Files and Folders",
      "subtitle": "Open the 'Privacy & Security → Files and Folders' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders",
      "autocomplete": "Privacy & Security → Files and Folders",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → FileVault",
      "title": "Privacy & Security → FileVault",
      "subtitle": "Open the 'Privacy & Security → FileVault' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?FileVault",
      "autocomplete": "Privacy & Security → FileVault",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Full Disk Access",
      "title": "Privacy & Security → Full Disk Access",
      "subtitle": "Open the 'Privacy & Security → Full Disk Access' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles",
      "autocomplete": "Privacy & Security → Full Disk Access",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Location Services",
      "title": "Privacy & Security → Location Services",
      "subtitle": "Open the 'Privacy & Security → Location Services' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices",
      "autocomplete": "Privacy & Security → Location Services",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
     {
      "uid": "Privacy & Security → Lockdown Mode",
      "title": "Privacy & Security → Lockdown Mode",
      "subtitle": "Open the 'Privacy & Security → Lockdown Mode' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?LockdownMode",
      "autocomplete": "Privacy & Security → Lockdown Mode",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Microphone",
      "title": "Privacy & Security → Microphone",
      "subtitle": "Open the 'Privacy & Security → Microphone' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone",
      "autocomplete": "Privacy & Security → Microphone",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Photos",
      "title": "Privacy & Security → Photos",
      "subtitle": "Open the 'Privacy & Security → Photos' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos",
      "autocomplete": "Privacy & Security → Photos",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Reminders",
      "title": "Privacy & Security → Reminders",
      "subtitle": "Open the 'Privacy & Security → Reminders' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders",
      "autocomplete": "Privacy & Security → Reminders",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Speech Recognition",
      "title": "Privacy & Security → Speech Recognition",
      "subtitle": "Open the 'Privacy & Security → Speech Recognition' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_SpeechRecognition",
      "autocomplete": "Privacy & Security → Speech Recognition",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Screen Saver",
      "title": "Screen Saver",
      "subtitle": "Open the 'Screen Saver' pane",
      "arg": "x-apple.systempreferences:com.apple.ScreenSaver-Settings.extension",
      "autocomplete": "Screen Saver",
      "icon": {
        "path": "./Images/ScreenSaver.png"
      }
    },
    {
      "uid": "Screen Time",
      "title": "Screen Time",
      "subtitle": "Open the 'Screen Time' pane",
      "arg": "x-apple.systempreferences:com.apple.preference.screentime",
      "autocomplete": "Screen Time",
      "icon": {
        "path": "./Images/ScreenTime.png"
      }
    },
    {
      "uid": "Sound",
      "title": "Sound",
      "subtitle": "Open the 'Sound' pane",
      "arg": "x-apple.systempreferences:com.apple.Sound-Settings.extension",
      "autocomplete": "Sound",
      "icon": {
        "path": "./Images/Sound.png"
      }
    },
    {
      "uid": "Spotlight",
      "title": "Spotlight",
      "subtitle": "Open the 'Spotlight' pane",
      "arg": "x-apple.systempreferences:com.apple.Spotlight-Settings.extension",
      "autocomplete": "Spotlight",
      "icon": {
        "path": "./Images/Spotlight.png"
      }
    },
    {
      "uid": "Touch ID & Password",
      "title": "Touch ID & Password",
      "subtitle": "Open the 'Touch ID & Password' pane",
      "arg": "x-apple.systempreferences:com.apple.preferences.password",
      "autocomplete": "Touch ID & Password",
      "icon": {
        "path": "./Images/TouchID.png"
      }
    },
    {
      "uid": "Trackpad",
      "title": "Trackpad",
      "subtitle": "Open the 'Trackpad' pane",
      "arg": "x-apple.systempreferences:com.apple.Trackpad-Settings.extension",
      "autocomplete": "Trackpad",
      "icon": {
        "path": "./Images/Trackpad.png"
      }
    },
    {
      "uid": "Users & Groups",
      "title": "Users & Groups",
      "subtitle": "Open the 'Users & Groups' pane",
      "arg": "x-apple.systempreferences:com.apple.Users-Groups-Settings.extension",
      "autocomplete": "Users & Groups",
      "icon": {
        "path": "./Images/UsersGroups.png"
      }
    },
    {
      "uid": "VPN",
      "title": "VPN",
      "subtitle": "Open the 'VPN' pane (if a VPN has been configured)",
      "arg": "x-apple.systempreferences:com.apple.NetworkExtensionSettingsUI.NESettingsUIExtension",
      "autocomplete": "VPN",
      "icon": {
        "path": "./Images/VPN.png"
      }
    },
    {
      "uid": "Wallet & Apple Pay",
      "title": "Wallet & Apple Pay",
      "subtitle": "Open the 'Wallet & Apple Pay' pane",
      "arg": "x-apple.systempreferences:com.apple.WalletSettingsExtension",
      "autocomplete": "Wallet & Apple Pay",
      "icon": {
        "path": "./Images/Wallet.png"
      }
    },
    {
      "uid": "Wallpaper",
      "title": "Wallpaper",
      "subtitle": "Open the 'Wallpaper' pane",
      "arg": "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension",
      "autocomplete": "Wallpaper",
      "icon": {
        "path": "./Images/Wallpaper.png"
      }
    },
    {
      "uid": "Wi-Fi",
      "title": "Wi-Fi",
      "subtitle": "Open the 'Wi-Fi' pane",
      "arg": "x-apple.systempreferences:com.apple.wifi-settings-extension",
      "autocomplete": "Wi-Fi",
      "icon": {
        "path": "./Images/WiFi.png"
      }
    }
  ]
}
EOF
