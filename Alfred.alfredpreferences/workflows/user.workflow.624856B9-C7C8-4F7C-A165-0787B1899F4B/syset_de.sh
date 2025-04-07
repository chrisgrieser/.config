#!/bin/zsh --no-rcs

cat <<EOF
{ "items":
  [
    {
      "uid": "Accessibility General",
      "title": "Bedienungshilfen",
      "match": "accessibility bedienungshilfen",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess",
      "autocomplete": "Bedienungshilfen",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Audio",
      "title": "Bedienungshilfen → Audio",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Audio“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Audio",
      "autocomplete": "Bedienungshilfen → Audio",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Hearing Devices",
      "title": "Bedienungshilfen → Hörhilfen",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Hörhilfen“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Hearing",
      "autocomplete": "Bedienungshilfen → Hörhilfen",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Captions",
      "title": "Bedienungshilfen → Untertitel",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Untertitel“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Captioning",
      "autocomplete": "Bedienungshilfen → Untertitel",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Audio Descriptions",
      "title": "Bedienungshilfen → Audiobeschreibungen",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Audiobeschreibungen“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Media_Descriptions",
      "autocomplete": "Bedienungshilfen → Audiobeschreibungen",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Display",
      "title": "Bedienungshilfen → Anzeige",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Anzeige“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display",
      "autocomplete": "Bedienungshilfen → Anzeige",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Keyboard",
      "title": "Bedienungshilfen → Tastatur",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Tastatur“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Keyboard",
      "autocomplete": "Bedienungshilfen → Tastatur",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Pointer Control",
      "title": "Bedienungshilfen → Zeigersteuerung",
      "match": "bedienungshilfen zeigersteuerung maus trackpad pointer",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Zeigersteuerung“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?PointerControl",
      "autocomplete": "Bedienungshilfen → Zeigersteuerung",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibilty → Switch Control",
      "title": "Bedienungshilfen → Schaltersteuerung",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Schaltersteuerung“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Switch",
      "autocomplete": "Bedienungshilfen → Schaltersteuerung",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → VoiceOver",
      "title": "Bedienungshilfen → VoiceOver",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → VoiceOver“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_VoiceOver",
      "autocomplete": "Bedienungshilfen → VoiceOver",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "Accessibility → Zoom",
      "title": "Bedienungshilfen → Zoomen",
      "subtitle": "Öffne die Systemeinstellung „Bedienungshilfen → Zoomen“",
      "arg": "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Zoom",
      "autocomplete": "Bedienungshilfen → Zoomen",
      "icon": {
        "path": "./Images/Accessibility.png"
      }
    },
    {
      "uid": "AirDrop & Handoff",
      "title": "AirDrop & Handoff",
      "subtitle": "Öffne die Systemeinstellung „AirDrop & Handoff“",
      "arg": "x-apple.systempreferences:com.apple.AirDrop-Handoff-Settings.extension",
      "autocomplete": "AirDrop & Handoff",
      "icon": {
        "path": "./Images/AirDrop.png"
      }
    },
    {
      "uid": "Appearance",
      "title": "Erscheinungsbild",
      "match": "erscheinungsbild aussehen darstellung",
      "subtitle": "Öffne die Systemeinstellung „Erscheinungsbild“",
      "arg": "x-apple.systempreferences:com.apple.Appearance-Settings.extension",
      "autocomplete": "Erscheinungsbild",
      "icon": {
        "path": "./Images/Appearance.png"
      }
    },
    {
      "uid": "Apple Account",
      "title": "Apple Account",
      "match": "apple account apple-id",
      "subtitle": "Öffne die Systemeinstellung „Apple Account“",
      "arg": "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane",
      "autocomplete": "Apple Account",
      "icon": {
        "path": "./Images/AppleID.png"
      }
    },
    {
      "uid": "Apple Intelligence & Siri",
      "title": "Apple Intelligence & Siri",
      "subtitle": "Öffne die Systemeinstellung „Apple Intelligence & Siri“",
      "arg": "x-apple.systempreferences:com.apple.Siri-Settings.extension*siri-sae",
      "autocomplete": "Apple Intelligence & Siri",
      "icon": {
        "path": "./Images/AppleIntelligence.png"
      }
    },
    {
      "uid": "Autofill & Passwords",
      "title": "Automatisch ausfüllen & Passwörter",
      "subtitle": "Öffne die Systemeinstellung „Automatisch ausfüllen & Passwörter“",
      "arg": "x-apple.systempreferences:com.apple.Passwords-Settings.extension",
      "autocomplete": "Automatisch ausfüllen & Passwörter",
      "icon": {
        "path": "./Images/Passwords.png"
      }
    },
    {
      "uid": "Battery",
      "title": "Batterie",
      "match": "batterie akku energie",
      "subtitle": "Öffne die Systemeinstellung „Batterie“",
      "arg": "x-apple.systempreferences:com.apple.preference.battery",
      "autocomplete": "Batterie",
      "icon": {
        "path": "./Images/Battery.png"
      }
    },
    {
      "uid": "Bluetooth",
      "title": "Bluetooth",
      "subtitle": "Öffne die Systemeinstellung „Bluetooth“",
      "arg": "x-apple.systempreferences:com.apple.BluetoothSettings",
      "autocomplete": "Bluetooth",
      "icon": {
        "path": "./Images/Bluetooth.png"
      }
    },
    {
      "uid": "Control Centre",
      "title": "Kontrollzentrum",
      "subtitle": "Öffne die Systemeinstellung „Kontrollzentrum“",
      "arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension",
      "autocomplete": "Kontrollzentrum",
      "icon": {
        "path": "./Images/ControlCentre.png"
      }
    },
	{
      "uid": "Control Centre → Menu Bar",
      "title": "Kontrollzentrum → Menüleiste",
      "subtitle": "Öffne die Systemeinstellung „Kontrollzentrum → Menüleiste“",
      "arg": "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension?MenuBar",
      "autocomplete": "Kontrollzentrum → Menüleiste",
      "icon": {
        "path": "./Images/ControlCentre.png"
      }
    },
    {
      "uid": "Desktop & Dock",
      "title": "Schreibtisch & Dock",
      "match": "schreibtisch dock desktop",
      "subtitle": "Öffne die Systemeinstellung „Schreibtisch & Dock“",
      "arg": "x-apple.systempreferences:com.apple.Desktop-Settings.extension",
      "autocomplete": "Schreibtisch & Dock",
      "icon": {
        "path": "./Images/DesktopDock.png"
      }
    },
    {
      "uid": "Displays",
      "title": "Displays",
      "subtitle": "Öffne die Systemeinstellung „Displays“",
      "arg": "x-apple.systempreferences:com.apple.Displays-Settings.extension",
      "autocomplete": "Displays",
      "icon": {
        "path": "./Images/Displays.png"
      }
    },
    {
      "uid": "Family",
      "title": "Familie",
      "match": "familie familienfreigabe family sharing",
      "subtitle": "Öffne die Systemeinstellung „Familie“",
      "arg": "x-apple.systempreferences:com.apple.preferences.FamilySharingPrefPane",
      "autocomplete": "Familie",
      "icon": {
        "path": "./Images/Family.png"
      }
    },
    {
      "uid": "Focus",
      "title": "Fokus",
      "match": "fokus modus focus mode",
      "subtitle": "Öffne die Systemeinstellung „Fokus“",
      "arg": "x-apple.systempreferences:com.apple.Focus-Settings.extension",
      "autocomplete": "Fokus",
      "icon": {
        "path": "./Images/Focus.png"
      }
    },
    {
      "uid": "Game Centre",
      "title": "Game Center",
      "match": "game center centre spiele zentrale",
      "subtitle": "Öffne die Systemeinstellung „Game Center“",
      "arg": "x-apple.systempreferences:com.apple.Game-Center-Settings.extension",
      "autocomplete": "Game Center",
      "icon": {
        "path": "./Images/GameCentre.png"
      }
    },
    {
      "uid": "Game Controllers",
      "title": "Gamecontroller",
      "match": "gamecontroller game controllers spiele controller joystick gamepad",      
      "subtitle": "Öffne die Systemeinstellung „Gamecontroller“ (falls angeschlossen)",
      "arg": "x-apple.systempreferences:com.apple.Game-Controller-Settings.extension",
      "autocomplete": "Gamecontroller",
      "icon": {
        "path": "./Images/GameControllers.png"
      }
    },
    {
      "uid": "General",
      "title": "Allgemein",
      "subtitle": "Öffne die Systemeinstellung „Allgemein“",
      "arg": "x-apple.systempreferences:com.apple.systempreferences.General",
      "autocomplete": "Allgemein",
      "icon": {
        "path": "./Images/General.png"
      }
    },
    {
      "uid": "General → About",
      "title": "Allgemein → Info",
      "match": "allgemein info über about systeminformationen",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Info“",
      "arg": "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension",
      "autocomplete": "Allgemein → Info",
      "icon": {
        "path": "./Images/About.png"
      }
    },    
    {
      "uid": "General → AppleCare & Warranty",
      "title": "Allgemein → AppleCare & Garantie",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → AppleCare & Garantie“",
      "arg": "x-apple.systempreferences:com.apple.Coverage-Settings.extension",
      "autocomplete": "Allgemein → AppleCare & Garantie",
      "icon": {
        "path": "./Images/Coverage.png"
      }
    },
    {
      "uid": "General → Date & Time",
      "title": "Allgemein → Datum & Uhrzeit",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Datum & Uhrzeit“",
      "arg": "x-apple.systempreferences:com.apple.preference.datetime",
      "autocomplete": "Allgemein → Datum & Uhrzeit",
      "icon": {
        "path": "./Images/DateTime.png"
      }
    },
    {
      "uid": "General → Device Management",
      "title": "Allgemein → Geräteverwaltung",
      "match": "allgemein geräteverwaltung profile profiles",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Geräteverwaltung“",
      "arg": "x-apple.systempreferences:com.apple.preferences.configurationprofiles",
      "autocomplete": "Allgemein → Geräteverwaltung",
      "icon": {
        "path": "./Images/Profiles.png"
      }
    },    
    {
      "uid": "General → Languages & Region",
      "title": "Allgemein → Sprache & Region",
      "match": "allgemein sprache region lokalisierung language localisation localization",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Sprache & Region“",
      "arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension",
      "autocomplete": "Allgemein → Sprache & Region",
      "icon": {
        "path": "./Images/LanguagesRegion.png"
      }
    },
    {
      "uid": "General → Languages & Region → Translation Languages",
      "title": "Allgemein → Sprache & Region → Sprachen zum Übersetzen",
      "match": "allgemein sprache region lokalisierung sprachen zum übersetzen language localisation localization translation languages",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Sprache & Region → Sprachen zum Übersetzen“",
      "arg": "x-apple.systempreferences:com.apple.Localization-Settings.extension?translation",
      "autocomplete": "Allgemein → Sprache & Region → Sprachen zum Übersetzen",
      "icon": {
        "path": "./Images/LanguagesRegion.png"
      }
    },
    {
      "uid": "General → Login Items",
      "title": "Allgemein → Anmeldeobjekte & Erweiterungen",
      "match": "allgemein anmeldeobjekte erweiterungen startobjekte extensions",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Anmeldeobjekte & Erweiterungen“",
      "arg": "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
      "autocomplete": "Allgemein → Anmeldeobjekte & Erweiterungen",
      "icon": {
        "path": "./Images/LoginItems.png"
      }
    },
    {
      "uid": "General → Sharing",
      "title": "Allgemein → Teilen",
      "match": "allgemein teilen sharing freigabe",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing",
      "autocomplete": "Allgemein → Teilen",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Internet Sharing",
      "title": "Allgemein → Teilen → Internetfreigabe",
      "match": "allgemein teilen internetfreigabe internet sharing",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Internetfreigabe“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Internet",
      "autocomplete": "Allgemein → Teilen → Internetfreigabe",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Printer Sharing",
      "title": "Allgemein → Teilen → Druckerfreigabe",
      "match": "allgemein teilen druckerfreigabe printer sharing",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Druckerfreigabe“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_PrinterSharing",
      "autocomplete": "Allgemein → Teilen → Druckerfreigabe",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Application Scripting",
      "title": "Allgemein → Teilen → Skriptfernsteuerung für Apps",
      "match": "allgemein teilen skriptfernsteuerung für apps remote application scripting apple apple event remote application sharing",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Skriptfernsteuerung für Apps“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteAppleEvent",
      "autocomplete": "Allgemein → Teilen → Skriptfernsteuerung für Apps",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Management",
      "title": "Allgemein → Teilen → Entfernte Verwaltung (ARD)",
      "match": "allgemein teilen entfernte verwaltung ard remote desktop management sharing",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Entfernte Verwaltung“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_ARDService",
      "autocomplete": "Allgemein → Teilen → Entfernte Verwaltung",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Remote Login",
      "title": "Allgemein → Teilen → Entfernte Anmeldung (SSH)",
      "match": "allgemein teilen entfernte anmeldung sharing remote login ssh",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Entfernte Anmeldung“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteLogin",
      "autocomplete": "Allgemein → Teilen → Entfernte Anmeldung",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Sharing → Screen Sharing",
      "title": "Allgemein → Teilen → Bildschirmfreigabe (VNC)",
      "match": "allgemein teilen bildschirmfreigabe screen sharing vnc",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Teilen → Bildschirmfreigabe“",
      "arg": "x-apple.systempreferences:com.apple.preferences.sharing?Services_ScreenSharing",
      "autocomplete": "Allgemein → Teilen → Bildschirmfreigabe",
      "icon": {
        "path": "./Images/Sharing.png"
      }
    },
    {
      "uid": "General → Software Update",
      "title": "Allgemein → Softwareupdate",
      "match": "allgemein softwareupdate update aktualisierung",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Softwareupdate“",
      "arg": "x-apple.systempreferences:com.apple.Software-Update-Settings.extension",
      "autocomplete": "Allgemein → Softwareupdate",
      "icon": {
        "path": "./Images/SoftwareUpdate.png"
      }
    },      
    {
      "uid": "General → Startup Disk",
      "title": "Allgemein → Startvolume",
      "match": "allgemein startvolume volume startup disk laufwerk festplatte ssd",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Startvolume“",
      "arg": "x-apple.systempreferences:com.apple.Startup-Disk-Settings.extension",
      "autocomplete": "Allgemein → Startvolume",
      "icon": {
        "path": "./Images/StartupDisk.png"
      }
    },
    {
      "uid": "General → Storage",
      "title": "Allgemein → Speicher",
      "match": "allgemein speicher ssd belegung memory",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Speicher“",
      "arg": "x-apple.systempreferences:com.apple.settings.Storage",
      "autocomplete": "Allgemein → Speicher",
      "icon": {
        "path": "./Images/Storage.png"
      }
    },
    {
      "uid": "General → Time Machine",
      "title": "Allgemein → Time Machine",
      "match": "allgemein time machine backup datensicherung sicherung",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Time Machine“",
      "arg": "x-apple.systempreferences:com.apple.Time-Machine-Settings.extension",
      "autocomplete": "Allgemein → Time Machine",
      "icon": {
        "path": "./Images/TimeMachine.png"
      }
    },
    {
      "uid": "General → Transfer or Reset",
      "title": "Allgemein → Übertragen oder zurücksetzen",
      "match": "allgemein übertragen oder zurücksetzen transfer reset migration",
      "subtitle": "Öffne die Systemeinstellung „Allgemein → Übertragen oder zurücksetzen“",
      "arg": "x-apple.systempreferences:com.apple.Transfer-Reset-Settings.extension",
      "autocomplete": "Allgemein → Übertragen oder zurücksetzen",
      "icon": {
        "path": "./Images/TransferReset.png"
      }
    },    
    {
      "uid": "iCloud",
      "title": "iCloud",
      "subtitle": "Öffne die Systemeinstellung „iCloud“",
      "arg": "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings:icloud",
      "autocomplete": "iCloud",
      "icon": {
        "path": "./Images/iCloud.png"
      }
    },
    {
      "uid": "Internet Accounts",
      "title": "Internetaccounts",
      "subtitle": "Öffne die Systemeinstellung „Internetaccounts“",
      "arg": "x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension",
      "autocomplete": "Internetaccounts",
      "icon": {
        "path": "./Images/InternetAccounts.png"
      }
    },
    {
      "uid": "Keyboard",
      "title": "Tastatur",
      "match": "tastatur keyboard kürzel tastenkürzel shortcuts",      
      "subtitle": "Öffne die Systemeinstellung „Tastatur“",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
      "autocomplete": "Tastatur",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Function Keys",
      "title": "Tastatur → Funktionstasten",
      "match": "tastatur funktionstasten f-tasten function keys",
      "subtitle": "Öffne die Systemeinstellung „Tastatur → Funktionstasten“",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?FunctionKeys",
      "autocomplete": "Tastatur → Funktionstasten",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Modifier Keys",
      "title": "Tastatur → Sondertasten",
      "match": "tastatur sondertasten modifiziertasten keyboard modifier keys",
      "subtitle": "Öffne die Systemeinstellung „Tastatur → Sondertasten“",
      "arg": "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts",
      "autocomplete": "Tastatur → Sondertasten",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Keyboard → Text Replacements",
      "title": "Tastatur → Textersetzungen",
      "match": "tastatur textersetzungen keyboard text replacements",
      "subtitle": "Öffne die Systemeinstellung „Tastatur → Textersetzungen“",
      "arg": "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?TextReplacements",
      "autocomplete": "Tastatur → Textersetzungen",
      "icon": {
        "path": "./Images/Keyboard.png"
      }
    },
    {
      "uid": "Mouse",
      "title": "Maus",
      "match": "maus magic mighty mouse",
      "subtitle": "Öffne die Systemeinstellung „Maus“ (falls angeschlossen)",
      "arg": "x-apple.systempreferences:com.apple.Mouse-Settings.extension",
      "autocomplete": "Maus",
      "icon": {
        "path": "./Images/Mouse.png"
      }
    },    
    {
      "uid": "Lock Screen",
      "title": "Sperrbildschirm",
      "match": "sperrbildschirm lock screen",
      "subtitle": "Öffne die Systemeinstellung „Sperrbildschirm“",
      "arg": "x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension",
      "autocomplete": "Sperrbildschirm",
      "icon": {
        "path": "./Images/LockScreen.png"
      }
    },
    {
      "uid": "Network",
      "title": "Netzwerk",
      "match": "netzwerk network firewall",
      "subtitle": "Öffne die Systemeinstellung „Netzwerk“",
      "arg": "x-apple.systempreferences:com.apple.Network-Settings.extension",
      "autocomplete": "Netzwerk",
      "icon": {
        "path": "./Images/Network.png"
      }
    },
    {
      "uid": "Notifications",
      "title": "Mitteilungen",
      "match": "mitteilungen push notifications",
      "subtitle": "Öffne die Systemeinstellung „Mitteilungen“",
      "arg": "x-apple.systempreferences:com.apple.preference.notifications",
      "autocomplete": "Mitteilungen",
      "icon": {
        "path": "./Images/Notifications.png"
      }
    },
    {
      "uid": "Printers & Scanners",
      "title": "Drucker & Scanner",
      "match": "drucker scanner printer laserdrucker tintenstrahl lpp ipp airprint canon brother hp jetdirect oki ricoh epson dymo fuji xerox kodak konica kyocera lexmark olivetti pantum samsung sharp toshiba lantronix",
      "subtitle": "Öffne die Systemeinstellung „Drucker & Scanner“",
      "arg": "x-apple.systempreferences:com.apple.Print-Scan-Settings.extension",
      "autocomplete": "Drucker & Scanner",
      "icon": {
        "path": "./Images/PrintersScanners.png"
      }
    },
    {
      "uid": "Privacy & Security General",
      "title": "Datenschutz & Sicherheit",
      "match": "datenschutz sicherheit privacy security",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit“",
      "arg": "x-apple.systempreferences:com.apple.preference.security",
      "autocomplete": "Datenschutz & Sicherheit",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Accessibility",
      "title": "Datenschutz & Sicherheit → Bedienungshilfen",
      "match": "datenschutz sicherheit bedienungshilfen privacy security accessibility",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Bedienungshilfen“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
      "autocomplete": "Datenschutz & Sicherheit → Bedienungshilfen",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Advertising",
      "title": "Datenschutz & Sicherheit → Apple-Werbung",
      "match": "datenschutz sicherheit apple-werbung telemetrie privacy security advertising ads tracking telemetry",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Apple-Werbung“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Advertising",
      "autocomplete": "Datenschutz & Sicherheit → Apple-Werbung",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → App Management",
      "title": "Datenschutz & Sicherheit → App-Verwaltung",
      "match": "datenschutz sicherheit app-verwaltung privacy security app management bundles",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → App-Verwaltung“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles",
      "autocomplete": "Datenschutz & Sicherheit → App-Verwaltung",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Automation",
      "title": "Datenschutz & Sicherheit → Automation",
      "match": "datenschutz sicherheit automation privacy security",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Automation“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation",
      "autocomplete": "Datenschutz & Sicherheit → Automation",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Bluetooth",
      "title": "Datenschutz & Sicherheit → Bluetooth",
      "match": "datenschutz sicherheit bluetooth privacy security",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Bluetooth“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth",
      "autocomplete": "Datenschutz & Sicherheit → Bluetooth",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Calendars",
      "title": "Datenschutz & Sicherheit → Kalender",
      "match": "datenschutz sicherheit kalender privacy security calendars",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Kalender“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars",
      "autocomplete": "Datenschutz & Sicherheit → Kalender",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Camera",
      "title": "Datenschutz & Sicherheit → Kamera",
      "match": "datenschutz sicherheit kamera privacy security camera",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Kamera“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera",
      "autocomplete": "Datenschutz & Sicherheit → Kamera",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Contacts",
      "title": "Datenschutz & Sicherheit → Kontakte",
      "match": "datenschutz sicherheit kontakte adressen adressbuch privacy security contacts address book",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Kontakte“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts",
      "autocomplete": "Datenschutz & Sicherheit → Kontakte",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Files and Folders",
      "title": "Datenschutz & Sicherheit → Dateien & Ordner",
      "match": "datenschutz sicherheit dateien ordner privacy security files folders",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Dateien & Ordner“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders",
      "autocomplete": "Datenschutz & Sicherheit → Dateien & Ordner",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → FileVault",
      "title": "Datenschutz & Sicherheit → FileVault",
      "match": "datenschutz sicherheit filevault privacy security",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → FileVault“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?FileVault",
      "autocomplete": "Datenschutz & Sicherheit → FileVault",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Full Disk Access",
      "title": "Datenschutz & Sicherheit → Festplattenvollzugriff",
      "match": "datenschutz sicherheit festplattenvollzugriff privacy security full disk access",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Festplattenvollzugriff“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles",
      "autocomplete": "Datenschutz & Sicherheit → Festplattenvollzugriff",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Location Services",
      "title": "Datenschutz & Sicherheit → Ortungsdienste",
      "match": "datenschutz sicherheit ortungsdienste standort privacy security location services",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Ortungsdienste“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices",
      "autocomplete": "Datenschutz & Sicherheit → Ortungsdienste",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Lockdown Mode",
      "title": "Datenschutz & Sicherheit → Blockierungsmodus",
      "match": "datenschutz sicherheit blockierungsmodus lockdown mode",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Blockierungsmodus“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?LockdownMode",
      "autocomplete": "Datenschutz & Sicherheit → Blockierungsmodus",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Microphone",
      "title": "Datenschutz & Sicherheit → Mikrofon",
      "match": "datenschutz sicherheit mikrofon mikrophon privacy security microphone",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Mikrofon“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone",
      "autocomplete": "Datenschutz & Sicherheit → Mikrofon",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Photos",
      "title": "Datenschutz & Sicherheit → Fotos",
      "match": "datenschutz sicherheit fotos bilder privacy security photos pictures images",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Fotos“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos",
      "autocomplete": "Datenschutz & Sicherheit → Fotos",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Reminders",
      "title": "Datenschutz & Sicherheit → Erinnerungen",
      "match": "datenschutz sicherheit erinnerungen reminders privacy security",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Erinnerungen“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders",
      "autocomplete": "Privacy & Security → Reminders",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Privacy & Security → Speech Recognition",
      "title": "Datenschutz & Sicherheit → Spracherkennung",
      "match": "datenschutz sicherheit spracherkennung privacy security speech recognition",
      "subtitle": "Öffne die Systemeinstellung „Datenschutz & Sicherheit → Spracherkennung“",
      "arg": "x-apple.systempreferences:com.apple.preference.security?Privacy_SpeechRecognition",
      "autocomplete": "Datenschutz & Sicherheit → Spracherkennung",
      "icon": {
        "path": "./Images/Privacy.png"
      }
    },
    {
      "uid": "Screen Saver",
      "title": "Bildschirmschoner",
      "match": "bildschirmschoner screen saver",
      "subtitle": "Öffne die Systemeinstellung „Bildschirmschoner“",
      "arg": "x-apple.systempreferences:com.apple.ScreenSaver-Settings.extension",
      "autocomplete": "Bildschirmschoner",
      "icon": {
        "path": "./Images/ScreenSaver.png"
      }
    },
    {
      "uid": "Screen Time",
      "title": "Bildschirmzeit",
      "match": "bildschirmzeit screen time",
      "subtitle": "Öffne die Systemeinstellung „Bildschirmzeit“",
      "arg": "x-apple.systempreferences:com.apple.preference.screentime",
      "autocomplete": "Bildschirmzeit",
      "icon": {
        "path": "./Images/ScreenTime.png"
      }
    },
    {
      "uid": "Sound",
      "title": "Ton",
      "match": "ton sound klang geräusche hinweiston ausgabe eingabe input output",
      "subtitle": "Öffne die Systemeinstellung „Ton“",
      "arg": "x-apple.systempreferences:com.apple.Sound-Settings.extension",
      "autocomplete": "Ton",
      "icon": {
        "path": "./Images/Sound.png"
      }
    },
    {
      "uid": "Spotlight",
      "title": "Spotlight",
      "match": "spotlight suche search",
      "subtitle": "Öffne die Systemeinstellung „Spotlight“",
      "arg": "x-apple.systempreferences:com.apple.Spotlight-Settings.extension",
      "autocomplete": "Spotlight",
      "icon": {
        "path": "./Images/Spotlight.png"
      }
    },
    {
      "uid": "Touch ID & Password",
      "title": "Touch ID & Passwort",
      "match": "touch id passwort kennwort passwörter kennwörter password",
      "subtitle": "Öffne die Systemeinstellung „Touch ID & Passwort“",
      "arg": "x-apple.systempreferences:com.apple.preferences.password",
      "autocomplete": "Touch ID & Passwort",
      "icon": {
        "path": "./Images/TouchID.png"
      }
    },
    {
      "uid": "Trackpad",
      "title": "Trackpad",
      "subtitle": "Öffne die Systemeinstellung „Trackpad“",
      "arg": "x-apple.systempreferences:com.apple.Trackpad-Settings.extension",
      "autocomplete": "Trackpad",
      "icon": {
        "path": "./Images/Trackpad.png"
      }
    },
    {
      "uid": "Users & Groups",
      "title": "Benutzer:innen & Gruppen",
      "match": "benutzerinnen benutzer gruppen users groups",
      "subtitle": "Öffne die Systemeinstellung „Benutzer:innen & Gruppen“",
      "arg": "x-apple.systempreferences:com.apple.Users-Groups-Settings.extension",
      "autocomplete": "Benutzer:innen & Gruppen",
      "icon": {
        "path": "./Images/UsersGroups.png"
      }
    },
    {
      "uid": "VPN",
      "title": "VPN",
      "subtitle": "Öffne die Systemeinstellung „VPN“ (falls eingerichtet)",
      "arg": "x-apple.systempreferences:com.apple.NetworkExtensionSettingsUI.NESettingsUIExtension",
      "autocomplete": "VPN",
      "icon": {
        "path": "./Images/VPN.png"
      }
    },
    {
      "uid": "Wallet & Apple Pay",
      "title": "Wallet & Apple Pay",
      "subtitle": "Öffne die Systemeinstellung „Wallet & Apple Pay“",
      "arg": "x-apple.systempreferences:com.apple.WalletSettingsExtension",
      "autocomplete": "Wallet & Apple Pay",
      "icon": {
        "path": "./Images/Wallet.png"
      }
    },
    {
      "uid": "Wallpaper",
      "title": "Hintergrundbild",
      "match": "hintergrundbild schreibtischhintergrund desktop wallpaper",
      "subtitle": "Öffne die Systemeinstellung „Hintergrundbild“",
      "arg": "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension",
      "autocomplete": "Hintergrundbild",
      "icon": {
        "path": "./Images/Wallpaper.png"
      }
    },
    {
      "uid": "Wi-Fi",
      "title": "WLAN",
      "match": "wlan wi-fi wifi netzwerk network",
      "subtitle": "Öffne die Systemeinstellung „WLAN“",
      "arg": "x-apple.systempreferences:com.apple.wifi-settings-extension",
      "autocomplete": "WLAN",
      "icon": {
        "path": "./Images/WiFi.png"
      }
    }
  ]
}
EOF
