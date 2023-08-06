#!/usr/bin/env zsh

# CONFIG
CUSTOM_ICON_FOLDER="$DOTFILE_FOLDER/_custom-app-icons"

#───────────────────────────────────────────────────────────────────────────────

if ! command -v iconsur &>/dev/null; then echo "iconsur not installed." && return 1; fi
cd "/Applications/" || return 1
APP=$(basename "$*" .app)
NONE_FOUND=0
INFO_WINDOW=0

# INFO "Vivaldi Apps" is internally still named "Chrome Apps"
[[ "$BROWSER_APP" == "Vivaldi" ]] && browser="Chrome" || browser="$BROWSER_APP"
PWA_FOLDER="$HOME/Applications/$browser Apps.localized"

#───────────────────────────────────────────────────────────────────────────────

case $APP in
"BetterZip")
	cp -f "$CUSTOM_ICON_FOLDER/BetterZip 2.icns" "$APP.app/Contents/Resources/$APP.icns"
	;;
"Neovide" | "neovide")
	cp -f "$CUSTOM_ICON_FOLDER/Neovide 1.icns" "$APP.app/Contents/Resources/$APP.icns"
	;;
"WezTerm")
	cp -f "$CUSTOM_ICON_FOLDER/Terminal WezTerm.icns" "$APP.app/Contents/Resources/terminal.icns"
	;;
"Steam")
	iconsur set "$APP.app"
	;;
"AppCleaner")
	cp -f "$CUSTOM_ICON_FOLDER/AppCleaner.icns" "$APP.app/Contents/Resources/$APP.icns"
	;;
"Slack")
	cp -f "$CUSTOM_ICON_FOLDER/Slack 3.icns" "$APP.app/Contents/Resources/electron.icns"
	;;
"Obsidian")
	cp -f "$CUSTOM_ICON_FOLDER/Obsidian Square.icns" "$APP.app/Contents/Resources/icon.icns"
	;;
"Discord")
	cp -f "$CUSTOM_ICON_FOLDER/Discord Black.icns" "$APP.app/Contents/Resources/electron.icns"
	;;
# "Brave Browser")
# 	cp -f "$CUSTOM_ICON_FOLDER/Brave Safari.icns" "$APP.app/Contents/Resources/app.icns"
# 	;;
"Alfred Preferences")
	osascript -e "tell application \"Finder\"
			open information window of (\"Alfred 5.app/Contents/Preferences/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Alfred Preferences.icns\""
	INFO_WINDOW=1
	;;
"Microsoft Word")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Word.icns\""
	INFO_WINDOW=1
	;;
"Microsoft Excel")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Excel.icns\""
	INFO_WINDOW=1
	;;
"Mimestream")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Mail.icns\""
	INFO_WINDOW=1
	;;
"Twitter")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Twitter.icns\""
	INFO_WINDOW=1
	;;
"YouTube")
	cd "$PWA_FOLDER" || exit 1
	cp -f "$CUSTOM_ICON_FOLDER/$APP.icns" "$PWA_FOLDER/$APP.app/Contents/Resources/app.icns"
	;;
"Netflix")
	cd "$PWA_FOLDER" || exit 1
	iconsur set Netflix.app &>/dev/null
	;;
"Twitch")
	cd "$PWA_FOLDER" || exit 1
	iconsur set Twitch.app &>/dev/null
	;;
"Tagesschau")
	cd "$PWA_FOLDER" || exit 1
	iconsur set Tagesschau.app &>/dev/null
	;;
"CrunchyRoll")
	cd "$PWA_FOLDER" || exit 1
	iconsur set CrunchyRoll.app &>/dev/null
	;;
*)
	NONE_FOUND=1
	;;
esac

#───────────────────────────────────────────────────────────────────────────────

# No icon found
if [[ $NONE_FOUND == 1 ]]; then
	echo -n "No icon set up for $APP."
	return 1
fi

# Info Window Icon
if [[ $INFO_WINDOW == 1 ]]; then
	sleep 0.15
	osascript -e 'tell application "System Events"
		keystroke tab
		keystroke "v" using {command down}
	end tell'
	sleep 0.15
	return 0 # need to manually paste and then restart
fi

# Restart
touch "$APP.app"
killall "Dock"
killall "$APP"
while pgrep -xq "$APP"; do sleep 0.1; done
sleep 0.1
open -a "$APP"
echo -n "$APP" # pass for notification
