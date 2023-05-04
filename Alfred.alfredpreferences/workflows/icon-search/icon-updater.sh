#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
CUSTOM_ICON_FOLDER="$DOTFILE_FOLDER/_custom-app-icons"
PWA_FOLDER="$HOME/Applications/Chrome Apps.localized" # INFO "Vivaldi Apps" is internally still named "Chrome Apps"

#───────────────────────────────────────────────────────────────────────────────

if ! command -v iconsur &>/dev/null; then echo -n "iconsur not installed." && exit 1; fi
cd "/Applications/" || exit 1
APP=$(basename "$*" .app)
NONE_FOUND=0
INFO_WINDOW=0

#───────────────────────────────────────────────────────────────────────────────

case $APP in
"BetterZip")
	cp -f "$CUSTOM_ICON_FOLDER/BetterZip 2.icns" "$APP.app/Contents/Resources/$APP.icns"
	;;
"Neovide" | "neovide")
	# cp -f "$CUSTOM_ICON_FOLDER/Neovim ascii.icns" "$APP.app/Contents/Resources/$APP.icns"
	cp -f "$CUSTOM_ICON_FOLDER/Neovide 1.icns" "$APP.app/Contents/Resources/$APP.icns"
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
"Vivaldi")
	cp -f "$CUSTOM_ICON_FOLDER/Vivaldi.icns" "$APP.app/Contents/Resources/app.icns"
	;;
"Alfred Preferences")
	osascript -e "tell application \"Finder\"
			open information window of (\"Alfred 5.app/Contents/Preferences/$APP.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Alfred 1.icns\""
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
	cp -f "$CUSTOM_ICON_FOLDER/$APP.icns" "$PWA_FOLDER/$APP.app/Contents/Resources/app.icns"
	;;
"PWAs")
	cd "$PWA_FOLDER" || exit 1
	iconsur set --local reddxxx.app &>/dev/null
	iconsur set --input="$CUSTOM_ICON_FOLDER" --scale=1.1 BunnyFap.app &>/dev/null
	iconsur set Tagesschau.app &>/dev/null
	iconsur set Netflix.app &>/dev/null
	iconsur set Twitch.app &>/dev/null
	iconsur set CrunchyRoll.app &>/dev/null
	cp -f "$CUSTOM_ICON_FOLDER/YouTube.icns" "$PWA_FOLDER/YouTube.app/Contents/Resources/app.icns"
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
	osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
	sleep 0.15
	return 0 # need to manually paste and then restart
fi

# Restart
if [[ "$APP" == "PWAs" ]]; then
	# All PWA update
	killall "Dock" # INFO pgrep-ing for the Dock does not work, since there is always a process called that?
	echo -n "All PWAs"
	open "$PWA_FOLDER"
	exit 0
else
	touch "$APP.app"
	killall "Dock"
	killall "$APP"
	while pgrep -q "$APP"; do sleep 0.1; done
	sleep 0.1
	open -a "$APP"
	echo -n "$APP" # pass for notification
fi
